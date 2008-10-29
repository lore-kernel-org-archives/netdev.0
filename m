From: Patrick McHardy <kaber@trash.net>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 17:40:54 +0100
Message-ID: <49089216.3010607@trash.net>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net> <20081029130313.GA7256@ff.dom.local> <49086074.3080208@trash.net> <20081029132243.GB7256@ff.dom.local> <4908649A.6010005@trash.net> <20081029140404.GC7256@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37692 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215AbYJ2Qk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 12:40:57 -0400
In-Reply-To: <20081029140404.GC7256@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Oct 29, 2008 at 02:26:50PM +0100, Patrick McHardy wrote:
> ...
>> I still don't follow - are you talking about the code with out
>> without this patch? In the later case, why should we call it
>> recursively without the need to do so?
> 
> I mean the current version (e.g. net-2.6). This comment reads that
> netif_nit_deliver() is needed when we bypass netif_receive_skb().
> But we call netif_receive_skb() from __vlan_hwaccel_rx(), and it's
> not clear if some skbs are not tapped 2x.

They could be, but in different states (device, vlan_tci, priority).
Bypassing refers to the first state of the skb.
