From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 15:24:07 -0700
Message-ID: <20080917152407.76230f0c.akpm@linux-foundation.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<200809171724.36269.paul.moore@hp.com>
	<20080917144842.7df59f9e.akpm@linux-foundation.org>
	<200809171812.59693.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sds@tycho.nsa.gov, jmorris@namei.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56991 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755905AbYIQWYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 18:24:47 -0400
In-Reply-To: <200809171812.59693.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2008 18:12:59 -0400
Paul Moore <paul.moore@hp.com> wrote:

> > We don't even know the extent of the damage yet.  Which distros were
> > affected? With which versions of which userspace packages?
> 
> Can I assume that the "right" thing to do would be to find the problem 
> and revert whatever change caused the issue, yes?  Or are we happy to 
> wait and see since the fallout so far has been minimal?

I don't think a revert is justified after all this time.  afaik I'm the
first person to notice the problem, and it's been out there for
multiple months.

However it would be good if we could find some not-completely-stinky
way of making the old userspace work.

otoh, people who are shipping 2.6.25- and 2.6.26-based distros probably
wouldn't want such a patch in their kernels anyway.

