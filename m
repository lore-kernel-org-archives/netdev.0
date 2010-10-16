From: "Fred ." <eldmannen@gmail.com>
Subject: How to change delayed ACKs?
Date: Sat, 16 Oct 2010 23:57:30 +0200
Message-ID: <AANLkTi=AW6NMHkjkbFF=jUCc7YD3Z2T9VatpR5aeh9LW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51314 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008Ab0JPV5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 17:57:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I play online games.
Someone told me about Leatrix Latency Fix.
http://www.wowinterface.com/downloads/info13581-LeatrixLatencyFix.html

ACKs are delayed. The latency fix works by changing setting to
decrease that delay.

On Windows it modifies 'TCPAckFrequency' in the registry.

On FreeBSD and Mac OS X;
sudo sysctl -w net.inet.tcp.delayed_ack=0

This key doesn't seem to exist on Linux.
error: "net.inet.tcp.delayed_ack" is an unknown key

Is there any way to reduce the delay of delayed ACKs in order to
increase performance in online gaming?

P.S im not subscribed to mailinglist
