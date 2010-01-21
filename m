From: Anders =?iso-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Thu, 21 Jan 2010 17:42:47 +0100 (CET)
Message-ID: <20100121.174247.769487074466946522.anders@netinsight.net>
References: <CDAFEDABF718A54BABD0DA5476695307443F1E8D@SHEXMB-01.global.atheros.com>
	<20100120.102704.295948365864962720.anders@netinsight.net>
	<CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Jie.Yang@Atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:38525 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753438Ab0AUQm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 11:42:59 -0500
In-Reply-To: <CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "JY" == Jie Yang <Jie.Yang@Atheros.com> writes:

 >> Have you tested NFS over TCP? The block-size the application
 >> uses can have an effect on this. What application did you
 >> use? Block-size?
 >> 
 JY> yes, I tested NFS over TCP.

One strange observation is that I can only reproduce this problem when
transmitting data from a NFS-server using TCP with Atheros
AR8121/AR8113/AR8114.

I've tried to reproduce the problem using test-programs, like nttcp
and netpipe, without any success. One observation is that the
test-programs *only* generates 1500 bytes IP-packets. When
the NFS-server sends data, a sequence of 1500 bytes IP-packets are
generated, ending with a shorter packet. And this last packet in the
sequence has 1500 in the IP-header length field, but is shorter.

/ Anders
