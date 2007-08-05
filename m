From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Sun, 5 Aug 2007 19:01:55 +0400
Message-ID: <20070805150154.GA32132@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708031741.18404.phillips@phunq.net> <20070804164438.GC14175@2ka.mipt.ru> <200708050106.58383.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708050106.58383.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 05, 2007 at 01:06:58AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> > DST original code worked as device mapper plugin too, but its two
> > additional allocations (io and clone) per block request ended up for
> > me as a show stopper.
> 
> Ah, sorry, I misread.  A show stopper in terms of efficiency, or in 
> terms of deadlock?

At least as in terms of efficiency. Device mapper lives in happy world
where memory does not end and allocations are fast.

-- 
	Evgeniy Polyakov
