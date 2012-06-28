From: "George B." <georgeb@gmail.com>
Subject: Sending Packet Much Larger Than MSS
Date: Thu, 28 Jun 2012 10:21:01 -0700
Message-ID: <CAJ2iOjQGrnhG7L1jDAXybJiG7O5OpnaDzw5UBEuN2kEWXYGUnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53235 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305Ab2F1RVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 13:21:03 -0400
Received: by wgbdr13 with SMTP id dr13so2429813wgb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 10:21:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am troubleshooting an issue and in the course of that noticed that a
machine running  2.6.38-11 (Ubuntu  2.6.38-11-server #48-Ubuntu SMP)
kernel is sending packets larger than the MSS advertized by the remote
host.  The local machine has a large MTU (9000) and the advertized MSS
of the remote machine is 1380 and here we have the local machine
sending a 2560 byte packet.

I have a screen capture of the flow at
http://i46.tinypic.com/10zmgyh.png but it is kind of small.  The
initial MSS shows 1380 and you see the packet highlighted in blue has
a length of 2560.  That it gets accepted and acked is a different
problem but to my mind it should not be sending a packet that large in
the first place.

Is this a known issue with that kernel?

Thanks.

George
