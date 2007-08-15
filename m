From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC: -mm patch] improve the SSB dependencies
Date: Tue, 14 Aug 2007 20:40:35 -0400
Message-ID: <20070815004035.GL7198@tuxdriver.com>
References: <200708110208.21624.mb@bu3sch.de> <200708111642.39348.mb@bu3sch.de> <20070811230855.GA8907@stusta.de> <200708121400.28297.mb@bu3sch.de> <20070812224401.GA18945@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4085 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758489AbXHOBHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 21:07:30 -0400
Content-Disposition: inline
In-Reply-To: <20070812224401.GA18945@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2007 at 12:44:02AM +0200, Adrian Bunk wrote:
> On Sun, Aug 12, 2007 at 02:00:26PM +0200, Michael Buesch wrote:
> > Ok, I'll give it a try, with small modifications.
> 
> Thanks.
> 
> > On Sunday 12 August 2007, Adrian Bunk wrote:
> > > Additional changes in this patch:
> > > - small help text changes
> > > - B44_PCI is no longer usr visible (automatically enabled when possible)
> > 
> > I think we want that to be selectable, as it's not needed
> > on some embedded devices. And we need to save memory there.
> >...
> 
> Makes sense, but then:
> 
> config B44_PCI
> 	bool "Broadcom 440x PCI device support" if EMBEDDED
> 	...
> 	default y
> 	...
> 
> I don't care about how many options we present if CONFIG_EMBEDDED=y, but 
> for the normal CONFIG_EMBEDDED=n case we should not bother the user with 
> this option.

Was all this resolved?  Was there another patch?  If so, I missed it...

John
-- 
John W. Linville
linville@tuxdriver.com
