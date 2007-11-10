From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 21:14:29 +0800
Message-ID: <20071110131428.GA6447@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2397 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750791AbXKJNOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 08:14:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

It looks like the addition of UDP-Lite has upset netstat:

$ netstat -s
Ip:
    1257344 total packets received
    6 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    1257338 incoming packets delivered
    1257151 requests sent out
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    0 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
Tcp:
    2 active connections openings
    3 passive connection openings
    0 failed connection attempts
    0 connection resets received
    1 connections established
    1257288 segments received
    1257134 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    30 packets received
    0 packets to unknown port received.
    0 packet receive errors
    17 packets sent
UdpLite:
error parsing /proc/net/snmp: Success
$

Should we remove it again or let it stay this time?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
