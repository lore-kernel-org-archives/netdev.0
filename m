From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Tue, 4 Oct 2011 15:54:50 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B91400C5F6@nsmail.netscout.com>
References: <6.2.5.6.2.20111001215241.03a7ed48@binnacle.cx> <1317540066.3802.32.camel@edumazet-laptop> <6.2.5.6.2.20111002110545.03a82460@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, "netdev" <netdev@vger.kernel.org>,
	"Willy Tarreau" <w@1wt.eu>,
	"Peter Zijlstra" <a.p.zijlstra@chello.nl>
To: <starlight@binnacle.cx>, "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <6.2.5.6.2.20111002110545.03a82460@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Sometimes I think it might be nice to run without
> an OS at all :-)
> 
> We are looking at various kernel bypass approaches
> for receiving packets and it's in my mind that
> one of these may get us to running on newer
> kernels without giving up performance.
> 

If permissible in your environment, try running PACKET:tpacket_v3.

Also, I always wondered about the following in the output of:

net/ptype
dada          edsa_rcv+0x0/0x246
001b          dsa_rcv+0x0/0x225

and so when I'm fine tuning apps in virtual environments I nuke the
above during kernel compilation.


Chetan Loke
