From: Al Boldi <a1426z@gawab.com>
Subject: Re: TCP throttling
Date: Tue, 20 Sep 2005 21:54:15 +0300
Message-ID: <200509202154.15995.a1426z@gawab.com>
References: <200509190646.57579.a1426z@gawab.com> <Pine.LNX.4.62.0509200717410.21650@uplift.swm.pp.se> <20050920091922.15b5664b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mikael Abrahamsson <swmike@swm.pp.se>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050920091922.15b5664b@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 20 Sep 2005 07:19:03 +0200 (CEST)
> Mikael Abrahamsson <swmike@swm.pp.se> wrote:
> > On Tue, 20 Sep 2005, Al Boldi wrote:
> > > Could you suggest sane values for 2.4/2.6 on a 100mbit link?
> >
> > Go for approx 2-8 megs of TCP window size and buffers.
>
> I use the following for testing over 1GE. You want
> at least 2x the delay bandwidth product.

ping 10.1 -s56

(RTT=0.250ms) * 100mbit = 3125000 Bytes

How much increase in thruput should be expected?

Thanks!

--
Al
