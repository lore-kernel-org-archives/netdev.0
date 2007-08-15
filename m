From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC: -mm patch] improve the SSB dependencies
Date: Wed, 15 Aug 2007 14:47:29 +0200
Message-ID: <200708151447.29968.mb@bu3sch.de>
References: <200708110208.21624.mb@bu3sch.de> <20070812224401.GA18945@stusta.de> <20070815004035.GL7198@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:60187
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbXHOMso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 08:48:44 -0400
In-Reply-To: <20070815004035.GL7198@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 15 August 2007 02:40:35 John W. Linville wrote:
> On Mon, Aug 13, 2007 at 12:44:02AM +0200, Adrian Bunk wrote:
> > On Sun, Aug 12, 2007 at 02:00:26PM +0200, Michael Buesch wrote:
> > > Ok, I'll give it a try, with small modifications.
> > 
> > Thanks.
> > 
> > > On Sunday 12 August 2007, Adrian Bunk wrote:
> > > > Additional changes in this patch:
> > > > - small help text changes
> > > > - B44_PCI is no longer usr visible (automatically enabled when possible)
> > > 
> > > I think we want that to be selectable, as it's not needed
> > > on some embedded devices. And we need to save memory there.
> > >...
> > 
> > Makes sense, but then:
> > 
> > config B44_PCI
> > 	bool "Broadcom 440x PCI device support" if EMBEDDED
> > 	...
> > 	default y
> > 	...
> > 
> > I don't care about how many options we present if CONFIG_EMBEDDED=y, but 
> > for the normal CONFIG_EMBEDDED=n case we should not bother the user with 
> > this option.
> 
> Was all this resolved?  Was there another patch?  If so, I missed it...

I am going to send one, soon.

-- 
Greetings Michael.
