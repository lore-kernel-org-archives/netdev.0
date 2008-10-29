From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 14:04:04 +0000
Message-ID: <20081029140404.GC7256@ff.dom.local>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net> <20081029130313.GA7256@ff.dom.local> <49086074.3080208@trash.net> <20081029132243.GB7256@ff.dom.local> <4908649A.6010005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:21441 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbYJ2OEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 10:04:12 -0400
Received: by ug-out-1314.google.com with SMTP id 39so615416ugf.37
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 07:04:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4908649A.6010005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 02:26:50PM +0100, Patrick McHardy wrote:
...
> I still don't follow - are you talking about the code with out
> without this patch? In the later case, why should we call it
> recursively without the need to do so?

I mean the current version (e.g. net-2.6). This comment reads that
netif_nit_deliver() is needed when we bypass netif_receive_skb().
But we call netif_receive_skb() from __vlan_hwaccel_rx(), and it's
not clear if some skbs are not tapped 2x.

Jarek P.
