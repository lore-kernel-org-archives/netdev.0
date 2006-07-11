From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Mon, 10 Jul 2006 21:25:36 -0700
Message-ID: <20060710212536.5a223977.akpm@osdl.org>
References: <200607110054.36520.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jbenc@suse.cz, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16513 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965136AbWGKE0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 00:26:09 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607110054.36520.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Jul 2006 00:54:33 +0200
Michael Buesch <mb@bu3sch.de> wrote:

> Please apply this to wireless-dev.
> Note that this is the second try to submit this patch.
> The first try contained a little bug. I'm sorry for that.
> If you already applied the first one, I can provide an incremental patch.
> 
> Note2 that this patch depends on the
> [PATCH] cancel_rearming_delayed_work infinite loop fix
> I just sent out to the lists and akpm.

Am still scratching my head over that.  I wouldn't really call it a "fix". 
More an enhcancement to cover unanticipated (and arguably strange) usage.

It's odd to call cancel_rearming_delayed_work() against a rearming
workqueue which isn't actually running.  It tends to indicate that the
caller has lost track of what it's up to.

But as a convenience thing I guess it's an OK thing to do.  I need to stare
at the implementation for a bit longer - that stuff's tricky.
