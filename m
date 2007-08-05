From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Sun, 5 Aug 2007 14:35:04 -0700
Message-ID: <200708051435.04542.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708050106.58383.phillips@phunq.net> <20070805150154.GA32132@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070805150154.GA32132@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 05 August 2007 08:01, Evgeniy Polyakov wrote:
> On Sun, Aug 05, 2007 at 01:06:58AM -0700, Daniel Phillips wrote:
> > > DST original code worked as device mapper plugin too, but its two
> > > additional allocations (io and clone) per block request ended up
> > > for me as a show stopper.
> >
> > Ah, sorry, I misread.  A show stopper in terms of efficiency, or in
> > terms of deadlock?
>
> At least as in terms of efficiency. Device mapper lives in happy
> world where memory does not end and allocations are fast.

Are you saying that things are different for a network block device 
because it needs to do GFP_ATOMIC allocations?  If so then that is just 
a misunderstanding.  The global page reserve Peter and I use is 
available in interrupt context just like GFP_ATOMIC.

Regards,

Daniel
