From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Problem with 2.4.24 e1000 and keepalived
Date: Wed, 7 Jan 2004 20:05:56 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040107200556.0d553c40.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Hello all,

I am looking for confirmation for the following problem.
Setup is a simple pair of routers with 2 nics each, all e1000. If you start a
vrrp setup with keepalived and interface state is down during keepalived
startup, then the failover does not work. If the nics are UP during startup
everything works well. Now the kernel part of the story: the exact same setup
works with tulip cards.
Is there a difference regarding UP/DOWN state handling/events in e1000 and
tulip. e100 and eepro100 show the same problem btw.

Any hints are welcome

Regards,
Stephan
