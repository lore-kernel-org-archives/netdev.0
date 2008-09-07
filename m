From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Userspace network stack release.
Date: Sun, 7 Sep 2008 20:51:53 +0400
Message-ID: <20080907165153.GB22577@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:40247 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbYIGQwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2008 12:52:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

New version of the userspace network stack includes sync with the
simplified netchannels interface and small bug fixes. I also dropped
routing table support, since userspace network stack is designed on
behalf of netchannels and thus efectively single opened object operates
with single source and destination peers, so there is no need to
introduce unneded caches, since all needed information can be stored in
the userspace network stack object itself.

Unetstack contains following features:
# TCP/UDP sending and receiving.
# Timestamp, window scaling, MSS TCP options.
# PAWS.
# Slow start and congestion control.
# Socket-like interface.
# IP and ethernet processing code.
# Complete retransmit algorithm.
# Fast retransmit support.
# Support for TCP listen state (peer-to-peer mode with single channel).
# Netchannels interface and packet socket support.

TODO list includes:
* libunetstack.so or libtcp.so library interface.
* SACK support

Links.
1. Userspace network stack (archive, benchmarks, description).
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

2. Netchannels.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

-- 
	Evgeniy Polyakov
