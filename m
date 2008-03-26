From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Wed, 26 Mar 2008 22:46:48 +0100
Message-ID: <20080326214648.GA16497@ami.dom.local>
References: <47EA7DE8.9070203@sun.com> <47EAAE9A.9050305@gmail.com> <47EAB158.3080806@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:45964 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756531AbYCZVgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 17:36:52 -0400
Received: by mu-out-0910.google.com with SMTP id i10so4982594mue.5
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 14:36:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47EAB158.3080806@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 01:26:00PM -0700, Matheos Worku wrote:
...
> Reproduced the lockup with irqbalance disabled and with single src of  
> interrupt (TX interrupt, UDP transmit).  Lockup appears in different  
> location though.
>
> Regards
> matheos
>
> irq of interest: 454 (TX interrupt)
>
>
> 454:      19249      93234     907186       2691          0        188    
>       0        160   PCI-MSI-edge      eth6
...
> .......
>
> 454:      19249     126519     907186       2691          0        188    
>       0        160   PCI-MSI-edge      eth6


Hmm... Is this before disabling or I miss something?

Of course, my hint could be wrong here, but there are some issues
around napi vs. irq balancing, so it would be interesting to check
this with all network cards irqs affinity set (and respected).

This could be interesting:
http://marc.info/?l=linux-netdev&m=120349568512423&w=2
(but I suspect there are possible other reasons yet)

Jarek P.
