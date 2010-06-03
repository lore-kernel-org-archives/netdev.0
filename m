From: Ivan Novick <novickivan@gmail.com>
Subject: 200 millisecond timeouts in TCP
Date: Thu, 3 Jun 2010 15:37:24 -0700
Message-ID: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50178 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071Ab0FCWh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 18:37:26 -0400
Received: by vws11 with SMTP id 11so711587vws.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 15:37:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Using tcpdump and systemtap I am seeing that sometimes retransmission
of data is sent after waiting 200 milliseconds.  However sometimes
retransmissions happen quicker.

Is there a specifc event that causes these 200 milisec delays to kick
in?  Are those events identifiable in netstat -s output?

Also do you know if the timeout numbers for TCP are configurable parameters?

I am testing on RHEL5 with this kernel: 2.6.18-164.15.1.el5.

Cheers,
Ivan Novick
