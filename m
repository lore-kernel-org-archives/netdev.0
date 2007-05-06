From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Merging SSB upstream
Date: Sun, 6 May 2007 20:44:51 +0200
Message-ID: <200705062044.52408.mb@bu3sch.de>
References: <200705060303.17594.mb@bu3sch.de> <200705061144.27817.mb@bu3sch.de> <20070506173833.GA4717@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org, mtakahashi-D/ILkEkFJBd3+QwDJ9on6Q@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070506173833.GA4717-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 06 May 2007 19:38:33 John W. Linville wrote:
> On Sun, May 06, 2007 at 11:44:27AM +0200, Michael Buesch wrote:
> > On Sunday 06 May 2007 04:00:51 John W. Linville wrote:
> 
> > > I had to remove 
> > > the b44 ssb changes from fedora because a) users reported problems;
> > 
> > Which problems were that? The 2 compile issues?
> > Trivial to fix if that's the only issue. ;)
> 
> I knew you would ask that... :-)

:P

> I don't think there was a bugzilla, but Dave Jones forwarded an email
> to me from "MASAO TAKAHASHI" in late February.  Takahashi-san (forgive
> me if I did that wrong) was complaining about tx timeouts after I
> had added the full wireless-dev patchset to rawhide.  Removing the
> b44 bits of the patch seemed to remove the problem.
> 
> That's all the info I have.  Perhaps Dave or Takahashi-san can add
> to the description?

Hm, interesting issue.
But I'm not convinced that it's caused by the SSB port, though.
What the SSB port essentially does is modifying small areas in the
init and exit paths. The modified things in the TX and RX hotpaths
are really tiny and trivial. TX timeout sounds like something in the
TX/RX paths is going wrong.
But anyway, maybe I got something wrong.
I'll run some burn-in tests on it now.

-- 
Greetings Michael.
