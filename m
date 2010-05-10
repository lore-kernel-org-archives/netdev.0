From: "Gerrit Binnenmars" <gerritbinnenmars@gmail.com>
Subject: Fw: Subnet broadcast MTU issue?
Date: Mon, 10 May 2010 21:51:21 +0200
Message-ID: <623F3F55DDA14658A341954348829D1A@GerritRita>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:41808 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969Ab0EJT7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 15:59:39 -0400
Received: by ewy20 with SMTP id 20so1107217ewy.1
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 12:59:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have configured an ethernet port at MTU 9000 with ifconfig
On this port I have an alias (with IP 192.168.100.254) for a network that 
support only an MTU of 1500, I added ip route change 192.168.100.0/24 dev 
eth0 src 192.168.100.254 mtu lock 1500.

Then ping -s 20000 192.168.100.253 works fine, with packets being fragmented 
as expected at 1500 bytes
but ping -b -s 20000 192.168.100.255 does not work, packets are fragmented 
at approx. 9000 bytes.

I tried ip route change table local broadcast 192.168.100.255 mtu lock 1500 
without success.

Is there a solution? Where in the source code is the MTU size for a 
broadcast message determined?

Thanks in advance,

Gerrit Binnenmars 

