From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 13:38:56 +0100
Message-ID: <16821.42080.932184.167780@robur.slu.se>
References: <20041206205305.GA11970@soohrt.org>
	<20041206134849.498bfc93.davem@davemloft.net>
	<20041206224107.GA8529@soohrt.org>
	<41B58A58.8010007@draigBrady.com>
	<20041207112139.GA3610@soohrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: P@draigBrady.com, "David S. Miller" <davem@davemloft.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261799AbULGMjM@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207112139.GA3610@soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hello!

Well my experience is that it very hard not to say almost impossible to=
=20
extrapolate idle cpu into any network system capacity. I guess this is=20
what you are trying to do?=20

Rather load and overload the system with traffic having the characteris=
tics
you expect as a bonus you will get some kind proof of robustness and=20
responsiveness a max load. There are tools for this type of tests.


P=E1draig! Very funny... I started hacking 2 hours ago on idea I=20
had for long time, This to do a light version of skb recycling based
skb->users (the pktgen trick) with very minimal kernel change..


> Anyway attached is a small patch that I used to make the e1000
> "own" the packet buffers, and hence it does not alloc/free
> per packet at all. Now this has only been tested in one
> configuration where I was just sniffing the packets, so
> definitely YMMV.

						--ro
