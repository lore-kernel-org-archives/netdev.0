From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with software LRO
Date: Fri, 20 Jun 2008 15:39:24 +0300
Message-ID: <200806201539.24421.opurdila@ixiacom.com>
References: <485B4ADE.8070102@domat.com.pl> <200806201309.35272.opurdila@ixiacom.com> <20080620110158.GA4299@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2112 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752893AbYFTMk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 08:40:57 -0400
In-Reply-To: <20080620110158.GA4299@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 June 2008, Jarek Poplawski wrote:

> If so, can't we make it all simpler now, without this new "error"
> variable, and simply skipping this: "if (spd->nr_pages - nr_pages)"
> test under "done:", so, doing this block unconditional or maybe (I
> didn't check this enough) changing this test a little to catch there
> this offset update for frag_list?

Let me try to wrap my brain around this again :) and see if we don't miss 
anything. In the process, maybe I can even find a way to make this code 
easier to understand.

Thanks,
tavi
