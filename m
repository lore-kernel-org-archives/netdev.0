From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [BNEP] Fix compat BNEPGETCONNLIST ioctl.
Date: Mon, 18 Sep 2006 17:09:14 +0200
Message-ID: <1158592154.25125.21.camel@localhost>
References: <1158573909.24527.336.camel@pmac.infradead.org>
	 <1158575899.25125.1.camel@localhost>
	 <1158585899.24527.356.camel@pmac.infradead.org>
	 <1158589163.24527.367.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:57732 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1751749AbWIRPJI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 11:09:08 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1158589163.24527.367.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

> > although HIDP mouse movement doesn't seem to be appearing
> > in /dev/input/mice on my G5, while the 'hcidump' output looks sane
> > enough while I move it. 
> 
> Ew, that's because struct hidp_connadd_req is similarly buggered for
> compat. Replacement HIDP patch to fix both at once... I didn't miss
> anywhere where we actually change the hidp_connadd_req structure during
> the call, did I?

that looks ugly, but I assume there is no other way to solve this
problem. I will go over all three patches and wrap them up nicely.

Linus, will you accept these for inclusion before 2.6.18 final?

Regards

Marcel


