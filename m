From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] Removal of debug code containing deprecated calls to cli()/sti()
Date: Fri, 18 Apr 2008 10:55:45 -0400
Message-ID: <200804181455.m3IEtje2032231@cmf.nrl.navy.mil>
References: <1208530262-8555-1-git-send-email-mark.asselstine@windriver.com>
Reply-To: chas3@users.sourceforge.net
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	asselsm@gmail.com
To: Mark Asselstine <mark.asselstine@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:36971 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbYDRO4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 10:56:22 -0400
In-reply-to: <1208530262-8555-1-git-send-email-mark.asselstine@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1208530262-8555-1-git-send-email-mark.asselstine@windriver.com>,Mar
k Asselstine writes:
>-#else /* !NS_DEBUG_SPINLOCKS */
> #define ns_grab_int_lock(card,flags) \
>         spin_lock_irqsave(&(card)->int_lock,(flags))
> #define ns_grab_res_lock(card,flags) \
>         spin_lock_irqsave(&(card)->res_lock,(flags))
> #define ns_grab_scq_lock(card,scq,flags) \
>         spin_lock_irqsave(&(scq)->lock,flags)
>-#endif /* NS_DEBUG_SPINLOCKS */

this patch should probably go one step farther and just remove these
spin_lock wrappers as well.  most people consider this bad form.
