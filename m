From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: 2.6.27-rc8-git7: Reported regressions from 2.6.26
Date: Sun, 5 Oct 2008 16:05:11 +0400
Message-ID: <20081005120511.GA27993@2ka.mipt.ru>
References: <200810051302.20896.rjw@sisk.pl> <E1KmS79-0003mo-5j@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1KmS79-0003mo-5j-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi.

On Sun, Oct 05, 2008 at 07:49:31PM +0800, Herbert Xu (herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org) wrote:
> Note that 2.6.27 beats 2.6.26 by 30% with bulk traffic over
> loopback as opposed to the small packets sent by tbench where
> I saw a 5% drop in performance on my machine.
> 
> So I'm not sure whether this should really be classified as
> a regression if we limit ourselves to the changes between 26
> and 27.
> 
> The changes prior to 26 seem to be more significant.

Yes, that's the point, TSO over loopback for big packets or workload
where there packets can be easily combined into big one results in a
fair performance improvement, but for small packets it regresses about
5-10 %. And yes, there are yet unresolved changes which caused bigger
performance degradation.

-- 
	Evgeniy Polyakov
