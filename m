From: "Martin Schiller" <mschiller@tdt.de>
Subject: RE: Suppress / delay SYN-ACK
Date: Wed, 18 Oct 2006 08:23:03 +0200
Message-ID: <001501c6f27d$ddcf4520$1a04010a@V505CP>
References: <200610171454.20193.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Lennert Buytenhek'" <buytenh@wantstofly.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:33424 "EHLO ns.tdt.de")
	by vger.kernel.org with ESMTP id S1751449AbWJRGXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 02:23:04 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id k9I6N3i20191
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 08:23:03 +0200
To: "'Eric Dumazet'" <dada1@cosmosbay.com>
In-Reply-To: <200610171454.20193.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, October 17, 2006 2:54 PM, Eric Dumazet wrote:
> 
> Well, did you solve Lennert problem if the final (third packet of
> three packet TCP establishment handshake) packet is missing ? It
> seems no timer will fire and tell you the socket is not usable... 
> 

Sorry, but I don't know what you exactly mean with this problem.

On my first short tests, when I send the SYN-ACK with the ioctl and don't
get an ACK, the first read on the socket returns "-1". So I can see that the
connection is not established and usable.

Martin


