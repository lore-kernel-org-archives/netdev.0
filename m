From: Patrick McHardy <kaber@trash.net>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 14:26:50 +0100
Message-ID: <4908649A.6010005@trash.net>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net> <20081029130313.GA7256@ff.dom.local> <49086074.3080208@trash.net> <20081029132243.GB7256@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33116 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbYJ2N0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 09:26:52 -0400
In-Reply-To: <20081029132243.GB7256@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Oct 29, 2008 at 02:09:08PM +0100, Patrick McHardy wrote:
>   
>>> As a matter of fact without this patch it's not so apparent why
>>> netif_receive_skb() can't happen after netif_nit_deliver() in
>>> __vlan_hwaccel_rx() too.
>>>       
>> I don't understand what you're saying.
>>     
>
> It's still about this bypassing: netif_receive_skb() can be called
> after netif_nit_deliver().
>   

I still don't follow - are you talking about the code with out
without this patch? In the later case, why should we call it
recursively without the need to do so?


