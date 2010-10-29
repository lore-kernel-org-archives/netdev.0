From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Fri, 29 Oct 2010 13:26:03 +0200
Message-ID: <20101029112603.GA24577@redhat.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
 <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com>
 <20101025161718.GA19559@redhat.com>
 <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain>
 <OFBB51646E.01CC3630-ON652577C8.0030D6EF-652577C8.0031DA3C@in.ibm.com>
 <20101026093846.GA6766@redhat.com>
 <OFBE9E2C99.648EFB19-ON652577C8.0035FEDD-652577C8.0036AD51@in.ibm.com>
 <20101026110913.GC7922@redhat.com>
 <OFC29C4491.59069AD1-ON652577CA.00170F0D-652577CA.001C76C8@LocalDomain>
 <OFE75E1E91.9722BFB3-ON652577CA.00256D94-652577CA.0027E1CE@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OFE75E1E91.9722BFB3-ON652577CA.00256D94-652577CA.0027E1CE@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 28, 2010 at 12:48:57PM +0530, Krishna Kumar2 wrote:
> > Krishna Kumar2/India/IBM wrote on 10/28/2010 10:44:14 AM:
> >
> > > > > > Results for UDP BW tests (unidirectional, sum across
> > > > > > 3 iterations, each iteration of 45 seconds, default
> > > > > > netperf, vhosts bound to cpus 0-3; no other tuning):
> > > > >
> > > > > Is binding vhost threads to CPUs really required?
> > > > > What happens if we let the scheduler do its job?
> > > >
> > > > Nothing drastic, I remember BW% and SD% both improved a
> > > > bit as a result of binding.
> > >
> > > If there's a significant improvement this would mean that
> > > we need to rethink the vhost-net interaction with the scheduler.
> >
> > I will get a test run with and without binding and post the
> > results later today.
> 
> Correction: The result with binding is is much better for
> SD/CPU compared to without-binding:

Can you pls ty finding out why that is?  Is some thread bouncing between
CPUs?  Does a wrong numa node get picked up?
In practice users are very unlikely to pin threads to CPUs.

-- 
MST
