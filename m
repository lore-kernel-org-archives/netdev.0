From: Harald Dunkel <harald.dunkel@t-online.de>
Subject: increase priority of tcp ACK packages in the kernel?
Date: Sat, 31 May 2008 09:10:23 +0200
Message-ID: <4840F9DF.5080106@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout10.t-online.de ([194.25.134.21]:50411 "EHLO
	mailout10.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYEaH3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 03:29:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

AFAICS there is a performance problem for tcp: High volume
outgoing traffic seriously affects throughput for incoming
traffic due to the tcp ACK packages waiting between the
giant packages in the outgoing fifo.

Do you think it would be possible to increase the priority of
outgoing tcp ACK packages in the kernel by default?

The performance improvement on busy lines can be pretty high,
as the before-after images on http://www.benzedrine.cx/ackpri.html
show for OpenBSD.

I have found some solutions for Linux using tc and iptables,
e.g.

     http://www.3e.me.uk/dm/
     http://shearer.org/Linux_Shaping_Template

But maybe there is a more general solution that I haven't seen
yet.


Regards

Harri

