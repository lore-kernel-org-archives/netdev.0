From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 04:34:12 +0200
Message-ID: <1333420452.18626.11.camel@edumazet-glaptop>
References: <1333417997.18626.1.camel@edumazet-glaptop>
	 <20120402.215911.1929019308299701014.davem@davemloft.net>
	 <1333419304.18626.5.camel@edumazet-glaptop>
	 <20120402.222300.1137842205135530387.davem@davemloft.net>
	 <4F7A60A4.5040600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, remi@remlab.net,
	levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F7A60A4.5040600@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-02 at 19:29 -0700, Rick Jones wrote:
> On 04/02/2012 07:23 PM, David Miller wrote:
> > From: Eric Dumazet<eric.dumazet@gmail.com>
> > Date: Tue, 03 Apr 2012 04:15:04 +0200
> >
> >> Any idea of a representative benchmark in dgram af_unix ?
> >
> > Maybe you could try to make bw_unix from lmbench use
> > SOCK_DGRAM? :-)
> 
> I don't know it isn't entirely bitrotted, but there are streaming and 
> datagram AF_UNIX tests in netperf - they require conditional inclusion 
> via ./configure --enable-unixdomain:
> 
> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#DG_005fSTREAM
> 

Ah yes of course, I'll try that.

BTW, do you have plans to support vmsplice()/splice() as a way to
provide 0-copy to TCP_STREAM ?

I ask this because I am currently working on fixing splice(pipe ->
socket) performance problem and need a standard benchmark to publish
performance results.

Thanks
