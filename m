From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP throttling
Date: Tue, 20 Sep 2005 09:19:22 -0700
Message-ID: <20050920091922.15b5664b@dxpl.pdx.osdl.net>
References: <200509190646.57579.a1426z@gawab.com>
	<20050919112008.17ad14f5@dxpl.pdx.osdl.net>
	<200509200654.23703.a1426z@gawab.com>
	<Pine.LNX.4.62.0509200717410.21650@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Al Boldi <a1426z@gawab.com>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Mikael Abrahamsson <swmike@swm.pp.se>
In-Reply-To: <Pine.LNX.4.62.0509200717410.21650@uplift.swm.pp.se>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2005 07:19:03 +0200 (CEST)
Mikael Abrahamsson <swmike@swm.pp.se> wrote:

> On Tue, 20 Sep 2005, Al Boldi wrote:
> 
> > Could you suggest sane values for 2.4/2.6 on a 100mbit link?
> 
> Go for approx 2-8 megs of TCP window size and buffers.

I use the following for testing over 1GE. You want
at least 2x the delay bandwidth product.

/etc/sysctl.conf
# increase Linux TCP buffer limits
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608

# increase Linux autotuning TCP buffer limits
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 65536 8388608
