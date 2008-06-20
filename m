From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
	software LRO
Date: Fri, 20 Jun 2008 13:01:29 +0000
Message-ID: <20080620130129.GA4417@ff.dom.local>
References: <485B4ADE.8070102@domat.com.pl> <200806201309.35272.opurdila@ixiacom.com> <20080620110158.GA4299@ff.dom.local> <200806201539.24421.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:53996 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbYFTM5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 08:57:11 -0400
Received: by ug-out-1314.google.com with SMTP id h2so1154518ugf.16
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 05:57:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806201539.24421.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 03:39:24PM +0300, Octavian Purdila wrote:
> On Friday 20 June 2008, Jarek Poplawski wrote:
> 
> > If so, can't we make it all simpler now, without this new "error"
> > variable, and simply skipping this: "if (spd->nr_pages - nr_pages)"
> > test under "done:", so, doing this block unconditional or maybe (I
> > didn't check this enough) changing this test a little to catch there
> > this offset update for frag_list?
> 
> Let me try to wrap my brain around this again :) and see if we don't miss 
> anything. In the process, maybe I can even find a way to make this code 
> easier to understand.
> 

Sure, no need to hurry, and after all, I'm OK with the current patch too.

Jarek P.
