From: Tuan Bui <tuan.d.bui@hp.com>
Subject: Re: [BUG REPORT] kernel panic in tcp_sendpage() on null pointer
 dereference
Date: Tue, 07 Apr 2015 17:01:20 -0700
Message-ID: <1428451280.3625.6.camel@u64>
References: <1428447453.4074.32.camel@u64>
	 <1428449613.25985.215.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org,
	Jason Low <jason.low2@hp.com>,
	Aswin Chandramouleeswaran <aswin@hp.com>,
	Jun Li <jun.li@hp.com>, Haris Volos <haris.volos@hp.com>,
	Wai Long <waiman.long@hp.com>,
	hideaki.yoshifuji@miraclelinux.com, alan@linux.intel.com,
	gw4pts@gw4pts.ampr.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428449613.25985.215.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-04-07 at 16:33 -0700, Eric Dumazet wrote:
> On Tue, 2015-04-07 at 15:57 -0700, Tuan Bui wrote:
> > Hi all,
> > 
> > I am consistently seeing this kernel panic on a 16 sockets machine
> > running Spark PageRank workload using Docker.  I am running RHEL 7.0
> > stock kernel which is 3.10.0-123.el7.x86_64.
> 
> Have you tried a recent upstream kernel ?
> 

Yes I have tried an upstream v4.0-rc4 kernel.  I was still getting the
same kernel panic.
