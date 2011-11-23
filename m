From: David Miller <davem@davemloft.net>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Tue, 22 Nov 2011 19:23:38 -0500 (EST)
Message-ID: <20111122.192338.1206677511966747729.davem@davemloft.net>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jlyo@jlyo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290Ab1KWAXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 19:23:44 -0500
In-Reply-To: <20111122181320.38a70cf8@telperion.jlyo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Young <jlyo@jlyo.org>
Date: Tue, 22 Nov 2011 18:13:20 -0600

> What's also puzzling, is that I see no packet drop reporting in
> $ ifconfig lo
> lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 16436  metric 1
> inet 127.0.0.1  netmask 255.0.0.0
> inet6 ::1  prefixlen 128  scopeid 0x10<host>
> loop  txqueuelen 0  (Local Loopback)
> RX packets 276411482  bytes 15822880567 (14.7 GiB)
> RX errors 0  dropped 0  overruns 0  frame 0
> TX packets 276411482 bytes 15822880567 (14.7 GiB)
> TX errors 0 dropped 0 overruns 0 carrier 0 collisions

The device driver therefore isn't even seeing the packets, they are
being dropped elsewhere.

Why is this "puzzling"?

There's layers upon layers and thousands of places where packets can
be dropped between the originating network stack and the actual device
driver.
