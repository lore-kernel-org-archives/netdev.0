From: Luca Dionisi <luca.dionisi@gmail.com>
Subject: Request: how do packet routing based on input gateway
Date: Sat, 24 Oct 2009 15:22:26 +0200
Message-ID: <73dbe2850910240622s2453c252p17d928f8a94ffe33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

I must instruct my server to route packets based on destination prefix
and on the gateway from which the packet arrived.
E.g.
 I am 192.168.0.1
 a packet for 192.168.1.0/24 which arrived from gateway 192.168.0.2
must go through 192.168.1.1 dev eth0
 a packet for 192.168.1.0/24 which arrived from gateway 192.168.0.3
must go through 192.168.1.2 dev eth1
 a packet for 192.168.1.0/24 which arrived from any other gateway must
go through 192.168.1.3 dev eth2

The gateway I mean is just the last hop traversed, before me. It's not
necessarily the source of the packet.

How am I supposed to do that?

Regards.
Luca Dionisi
