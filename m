From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Tue, 11 Jul 2006 12:12:53 +0200
Message-ID: <200607111212.53730.mb@bu3sch.de>
References: <200607110054.36520.mb@bu3sch.de> <200607111111.28040.mb@bu3sch.de> <20060711023100.6d117264.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jbenc@suse.cz, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:6113
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750921AbWGKKLX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 06:11:23 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060711023100.6d117264.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 11 July 2006 11:31, you wrote:
> On Tue, 11 Jul 2006 11:11:27 +0200
> Michael Buesch <mb@bu3sch.de> wrote:
> 
> > But I think the following is also broken in the old code:
> > A wq is not pending anymore, but just executing (before it reschedules itself).
> > I think that would also loop forever. I don't think that's what we want.
> > Because we can't really keep track of _this_.
> 
> The present implementation assumes that the handler will re-arm itself.
> 
> I agree that extending that makes sense.  But beware that it's easy to
> leave subtle holes in this logic.  Needs careful thought to get right.

Yeah, as I said. There is still a race.
Should I redo the patch to fix it?

-- 
Greetings Michael.
