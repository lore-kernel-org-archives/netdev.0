From: "valent.turkovic@gmail.com" <valent.turkovic@gmail.com>
Subject: Equal bandwidth for all users - Per Connection Queue (PCQ) on Linux ?
Date: Thu, 20 Sep 2012 15:22:32 +0200
Message-ID: <CAD=nrE8URRsz5aEWqH23TpVxQUn87SpUwR-qF8J2r+VH0j4cBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:58247 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab2ITNWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 09:22:33 -0400
Received: by weyx8 with SMTP id x8so1262577wey.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 06:22:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
is ther any way that would allow to dynamically distribute bandwidth
per conneted client?
For example if maximum bandiwdth available is 10/10 MBits/s and only
two clients are connected then they both get 1/2 (5/5 Mbits), and when
there are 10 clients connected and using the connection, each gets
1/10 (1/1 Mbit).

I haven't yet seen any qos technique on linux that allows this, but my
quess is that some linux networking guru has this figured out.

Mikrorik (linux based embedded OS specialized for networking) has qos
type called PCQ [1] that dynamically spreads bandwidth just as
explained.

[1] http://wiki.mikrotik.com/wiki/Manual:Queues_-_PCQ_Examples

-- 
follow me - www.twitter.com/valentt & http://kernelreloaded.blog385.com
linux, anime, spirituality, wireless, scuba, linuxmce smart home, zwave
ICQ: 2125241, Skype: valent.turkovic, MSN: valent.turkovic@hotmail.com
