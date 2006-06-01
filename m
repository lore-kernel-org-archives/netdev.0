From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.17-rc4: netfilter LOG messages truncated via NETCONSOLE
Date: Thu, 1 Jun 2006 11:11:25 +0200
Message-ID: <20060601091124.GA31642@janus>
References: <20060531094626.GA23156@janus> <447DAEC9.3050003@trash.net> <20060531160611.GA25637@janus> <447DC613.10102@trash.net> <20060531172936.GB25788@janus> <447DD66C.30605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932112AbWFAJL1@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <447DD66C.30605@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 07:46:20PM +0200, Patrick McHardy wrote:

[...]

> > ip -s link doesn't show any
> > dropped packets so far with any patch and I don't use traffic control
> > that I'm aware of. But I'm not sure what to make of "tc" output, maybe
> > because CONFIG_SHAPER is not set:
> > 
> > 	# tc -s -d qdisc show
> > 	RTNETLINK answers: Invalid argument
> > 	Dump terminated
> 
> Thats because you're missing CONFIG_NET_SCHED. Please enable it and
> try the tc command again, without it we can't see whether the qdisc
> (which is present even without CONFIG_NET_SCHED) just dropped the
> packets.

ok, now "tc -s -d qdisc show" says (after noticing missing netconsole
packets):

qdisc pfifo_fast 0: dev eth0 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 155031 bytes 2067 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

-- 
Frank
