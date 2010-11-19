From: Simon Horman <horms@verge.net.au>
Subject: Re: error while building the kernel Mainline
Date: Fri, 19 Nov 2010 09:20:03 +0900
Message-ID: <20101119002003.GA4511@verge.net.au>
References: <20101118.125451.98885354.davem@davemloft.net>
 <20101118130318.073f6beb.randy.dunlap@oracle.com>
 <20101118.131004.58430322.davem@davemloft.net>
 <20101118.131527.45904827.davem@davemloft.net>
 <4CE59F3F.3080407@trash.net>
 <4CE5BB30.5080209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, randy.dunlap@oracle.com,
	eric.dumazet@gmail.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CE5BB30.5080209@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2010 at 03:48:00PM -0800, Justin P. Mattock wrote:
> On 11/18/2010 01:48 PM, Patrick McHardy wrote:
> >Am 18.11.2010 22:15, schrieb David Miller:
> >>From: David Miller<davem@davemloft.net>
> >>Date: Thu, 18 Nov 2010 13:10:04 -0800 (PST)
> >>
> >>>From: Randy Dunlap<randy.dunlap@oracle.com>
> >>>Date: Thu, 18 Nov 2010 13:03:18 -0800
> >>>
> >>>>On Thu, 18 Nov 2010 12:54:51 -0800 (PST) David Miller wrote:
> >>>>
> >>>>>From: Patrick McHardy<kaber@trash.net>
> >>>>>Date: Thu, 18 Nov 2010 21:32:11 +0100
> >>>>>
> >>>>>>Thanks for testing. Dave, please apply directly, thanks!
> >>>>
> >>>>Dave,
> >>>>
> >>>>This patch does not fix the config/build error that I posted for linux-next.
> >>>
> >>>And it has bugs, now when NF_CONNTRACT is set to "m" IPVS isn't offered
> >>>at all.
> >>>
> >>>So I'm reverting.
> >>
> >>Ignore this, I was looking for "*_IPVS" in the config instead of
> >>"*_IP_VS" for some stupid reason.
> >
> >I always make the same mistake :)
> >
> >>Patch is sane and I'll look into Randy's problem when I get a chance.
> >>:-)
> >
> >I've already asked the tproxy guys to look into this, it's a
> >different problem that requires more tproxy knowledge than
> >have.
> >
> 
> 
> go outside to clean the garage, and put up the christmas lights up,
> come back and am freaking for a second that the problems not
> fixed...
> 
> tripping me out man!!

On a similar note, sorry for not participating in the IPVS portion of
this thread, it was all over by the time that I woke up this morning.
