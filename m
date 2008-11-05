From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: time for TCP ECN defaulting to on?
Date: Tue, 04 Nov 2008 17:16:03 -0800
Message-ID: <1225847763.11369.43.camel@HP1>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
 <49107543.5080207@blueteddy.net>
 <20081104.145242.112948002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@blueteddy.net" <linux-kernel@blueteddy.net>,
	"daniel.blueman@gmail.com" <daniel.blueman@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20081104.145242.112948002.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2008-11-04 at 14:52 -0800, David Miller wrote:
> From: Dave Hudson <linux-kernel@blueteddy.net>
> Date: Tue, 04 Nov 2008 16:16:03 +0000
> 
> > Daniel J Blueman wrote:
> > > Is it time to enable TCP ECN per default and get the benefits, since
> > > router support has been around and known-about for really considerable
> > > time?
> > > Perhaps it should be a question of enabling it, and educating people
> > > to disable it if they run into issues, since we'll probably be in the
> > > same situation in 5 years...and it'll be some time before these
> > > kernels hit devices/servers anyway.
> > > Daniel
> >
> > Unfortunately I think you'll find there are sufficiently large
> > numbers of broken SOHO routers out there that if you try this you'll
> > cause a lot of problems.  The problems range from no connectivity to
> > in a few extreme cases routers actually crashing or behaving in very
> > unpredictable ways.  Here's one summary that got presented to the
> > IETF about 18 months ago:
> >
> > http://www.ietf.org/proceedings/07mar/slides/tsvarea-3/sld6.htm
> 
> Another issue is that, even if we turn it on by default, it won't
> be on for a significant number of network cards out there.
> 
> This is because TSO, which is on by default, doesn't support ECN
> in many implementations.

I think this is no longer a limitation.  The GSO code will take care of
ECN properly if the hardware does not support it when doing TSO.


