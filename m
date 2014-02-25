From: Igor Vasilkov <igorv.sh@gmail.com>
Subject: Wireless Multicast Forwarding with OpenWRT
Date: Tue, 25 Feb 2014 18:19:44 +0400
Message-ID: <CAMERYnsFK2aswqa7tjt6B7r67fFp69CkU-gVX8aZfRkweKD5Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:35476 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbaBYOUF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 09:20:05 -0500
Received: by mail-ob0-f177.google.com with SMTP id wp18so8686800obc.36
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 06:20:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to connect an STB device over wi-fi to the router. STB uses
multicast only. Using udpxy is not possible. Original firmware
forwards multicast over wi-fi using mac changing technique. I.e.
router changes destination mac address from multicast to unicast mac
address of multicast group subscriber. On Asus routers this feature is
called "Wireless Multicast Forwarding (WMF)". On Mikrotik it's called
"Multicast-helper". So, the question is: How I can  implement this on
TP-link wr741nd with =D0=9EpenWrt? It works in original firmware. How i=
s it
implemented? Is it a feature of wi-fi chip driver or kernel patch or
patch of igmpproxy or something else?

igorv.sh@gmail.com
