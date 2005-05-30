From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] use mmiowb in tg3_poll
Date: Mon, 30 May 2005 09:30:13 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505300925570.11645@linux.site>
References: <200410211628.06906.jbarnes@engr.sgi.com>
 <Pine.LNX.4.33.0410221345400.392-100000@localhost.localdomain>
 <20050528231209.GA8456@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, jesse.barnes@intel.com, gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050528231209.GA8456@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 29 May 2005, Lennert Buytenhek wrote:

> .....
> I'm quite curious what kind of MMIO read latency you see on your
> Altix boxen.  This app is quite useful for determining those figures
> on x86{,_64} machines:
> 
> 	http://svn.gnumonks.org/trunk/mmio_test/mmio_test.c
> ....

[cc list change: jbarnes@engr.sgi.com -> jesse.barnes@intel.com]

Haven't tried this program yet (though it looks interesting.) 
In the past I've instrumented the driver with get_cycles() to 
acquire the PIO read and mmiowb() latencies.

I quickly looked through the records that I have and, unfortunately, 
wasn't able to locate raw data. But I found some scrawlings in my 
notes which say the most recent measurements for an Altix are: 

	i)  PIO read latency ~ 2.4 usec
	ii) mmiowb() latency ~ 1.1 usec

(This data was taken when the PIOs/mmiowb()s were coming from a CPU 
which was "nearest" to the NIC.)

If you have data for x86{,_64}, I'd be interested in that, too.

--
Arthur
