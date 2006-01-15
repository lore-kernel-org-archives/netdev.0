From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: wireless: recap of current issues (stack)
Date: Sun, 15 Jan 2006 11:04:05 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0601151056140.31304@p15091797.pureserver.info>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com>
 <20060113213200.GG16166@tuxdriver.com> <Pine.LNX.4.58.0601141448480.5587@p15091797.pureserver.info>
 <20060114204211.72942d45.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ulrich Kunitz <kune@deine-taler.de>, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dsd@gentoo.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751893AbWAOKEd@vger.kernel.org>
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20060114204211.72942d45.zaitcev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Jan 2006, Pete Zaitcev wrote:

> On Sat, 14 Jan 2006 15:13:39 +0100 (CET), Ulrich Kunitz <kune@deine-taler.de> wrote:
> 
> > [...] Register accesses in USB devices should be
> > able to sleep. However the 80211 stacks I've seen so far have a
> > fixed set of capabilities and do also assume, that at the driver
> > layer everything can be done in atomic mode, which is only true
> > for buses that support memory-mapping.
> 
> If this problem is real, then it's serious. However, I'm not seeing it
> with prism54usb and Berg's softmac (yet?). Would you be so kind to provide
> the file name and function name for the code which makes these assumptions?
> 
> Thanks,
> -- Pete
> 

Pete,

I've been wrong.

I couldn't find the problem in the latest version of the
ieee80211softmac. Thank you for noticing me.

Uli

-- 
Ulrich Kunitz - kune@deine-taler.de
