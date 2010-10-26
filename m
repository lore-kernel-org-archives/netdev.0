From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 26 Oct 2010 15:31:39 +0530
Message-ID: <OFBE9E2C99.648EFB19-ON652577C8.0035FEDD-652577C8.0036AD51@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101025161718.GA19559@redhat.com> <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain> <OFBB51646E.01CC3630-ON652577C8.0030D6EF-652577C8.0031DA3C@in.ibm.com> <20101026093846.GA6766@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101026093846.GA6766@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> "Michael S. Tsirkin" <mst@redhat.com>
>
> On Tue, Oct 26, 2010 at 02:38:53PM +0530, Krishna Kumar2 wrote:
> > Results for UDP BW tests (unidirectional, sum across
> > 3 iterations, each iteration of 45 seconds, default
> > netperf, vhosts bound to cpus 0-3; no other tuning):
>
> Is binding vhost threads to CPUs really required?
> What happens if we let the scheduler do its job?

Nothing drastic, I remember BW% and SD% both improved a
bit as a result of binding. I started binding vhost thread
after Avi suggested it in response to my v1 patch (he
suggested some more that I haven't done), and have been
doing only this tuning ever since. This is part of his
mail for the tuning:

> 		 vhost:
> 		 		 thread #0:  CPU0
> 		 		 thread #1:  CPU1
> 		 		 thread #2:  CPU2
> 		 		 thread #3:  CPU3

I simply bound each thread to CPU0-3 instead.

Thanks,

- KK

