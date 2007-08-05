From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Sun, 5 Aug 2007 01:06:58 -0700
Message-ID: <200708050106.58383.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708031741.18404.phillips@phunq.net> <20070804164438.GC14175@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070804164438.GC14175@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 04 August 2007 09:44, Evgeniy Polyakov wrote:
> > On Tuesday 31 July 2007 10:13, Evgeniy Polyakov wrote:
> > >     * storage can be formed on top of remote nodes and be
> > > exported simultaneously (iSCSI is peer-to-peer only, NBD requires
> > > device mapper and is synchronous)
> >
> > In fact, NBD has nothing to do with device mapper.  I use it as a
> > physical target underneath ddraid (a device mapper plugin) just
> > like I would use your DST if it proves out.
>
> I meant to create a storage on top of several nodes one needs to have
> device mapper or something like that on top of NBD itself. To further
> export resulted device one needs another userspace NDB application
> and so on. DST simplifies that greatly.
>
> DST original code worked as device mapper plugin too, but its two
> additional allocations (io and clone) per block request ended up for
> me as a show stopper.

Ah, sorry, I misread.  A show stopper in terms of efficiency, or in 
terms of deadlock?

Regards,

Daniel
