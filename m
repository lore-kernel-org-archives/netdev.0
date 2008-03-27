From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 11:33:40 +0100
Message-ID: <20080327103340.GB2845@ami.dom.local>
References: <47EA7DE8.9070203@sun.com> <47EAAE9A.9050305@gmail.com> <47EAB158.3080806@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:32867 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756601AbYC0K2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 06:28:51 -0400
Received: by ug-out-1314.google.com with SMTP id z38so302539ugc.16
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 03:28:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47EAB158.3080806@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 01:26:00PM -0700, Matheos Worku wrote:
...
> nsn57-110 login: BUG: soft lockup - CPU#2 stuck for 11s!  
...
> Call Trace:
> [<ffffffff803ef5f6>] __skb_clone+0x24/0xdc
> [<ffffffff803f152e>] skb_realloc_headroom+0x30/0x63
> [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
> [<ffffffff80221995>] gart_map_single+0x0/0x70
> [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246
...

Maybe I'm wrong with this again, but I wonder about this gart_map_single
on almost all traces, and probably not supposed to be seen here. Did you
try with some memory re-config/debugging?

Regards,
Jarek P.
