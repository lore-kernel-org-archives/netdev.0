From: "Sumit" <sumit@elitecore.com>
Subject: RE: forcing a packet to go through hw net device
Date: Tue, 10 May 2005 11:32:17 +0530
Message-ID: <HGEFKOBCHAIJDIEJLAKDIECOCBAA.sumit@elitecore.com>
References: <200505091458.42118.Jeff@steinhagen.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=Windows-1252
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff' R. Steinhagen" <Jeff@steinhagen.ch>, <netdev@oss.sgi.com>
In-Reply-To: <200505091458.42118.Jeff@steinhagen.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check out netfilter ROUTE target.
All the best,
-- Sumit

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
> Behalf Of 'Jeff' R. Steinhagen
>
> Hi!
>
> I have a (maybe trivial) question about the kernel's networking code:
>
> A packet with an "outside" destination goes through all layers
> including the
> hardware interface (user->socket->protocol->IP->HW). However if
> the packet is
> addressed to a local IP the transport through and checks by the hardware
> layer are avoided. This is perfectly OK for "normal" network usage.
>
> I am profiling some network hardware and related code. Is it
> possible to force
> an internally generated packet to be send through all/the hardware layers?
>
