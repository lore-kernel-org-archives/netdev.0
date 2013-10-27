From: anirup dutta <adutta2@uh.edu>
Subject: Netem Delay Normal Distribution
Date: Sat, 26 Oct 2013 21:31:03 -0500
Message-ID: <CAJx7G_xkrVkC7HGQZogivA_6-i2Gas6aJd-sOFNMEbmq8=cS0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:42753 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892Ab3J0CbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 22:31:04 -0400
Received: by mail-oa0-f46.google.com with SMTP id g12so2374233oah.33
        for <netdev@vger.kernel.org>; Sat, 26 Oct 2013 19:31:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I try this on my device

sudo tc qdisc del dev eth0 root netem delay 100ms 20ms distribution normal

I use iperf for transmitting UDP packets and I modified its code to
get per packet delay. When I plot the distribution of delays and
analyze the delays they pass the normality tests.

The only problem that I am not able to understand is that the mean of
those delays shift to 125ms. Its not only me. There was another study
and it observed the same thing.

http://www.researchgate.net/publication/224256550_An_Empirical_Study_of_NetEm_Network_Emulation_Functionalities/file/d912f5058c9b1e409b.pdf

Figure 7

I found out that this command is valid

sudo tc qdisc del dev eth0 root netem delay 1ms 20ms distribution normal

So I have a feeling that mean gets shifted from the base delay to
avoid negative delay values.

It would be great if someone can confirm how it is implemented?

Regards,

Anirup
