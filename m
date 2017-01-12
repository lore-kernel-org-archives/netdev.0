From: Mason <slash.tmp@free.fr>
Subject: Setting link down or up in software
Date: Thu, 12 Jan 2017 14:05:14 +0100
Message-ID: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:39011 "EHLO
        smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdALNwc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:52:32 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
        by smtpfb2-g21.free.fr (Postfix) with ESMTP id 99B9FD309ED
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 14:05:29 +0100 (CET)
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm wondering what are the semantics of calling

	ip link set dev eth0 down

I was expecting that to somehow instruct the device's ethernet driver
to shut everything down, have the PHY tell the peer that it's going
away, maybe even put the PHY in some low-power mode, etc.

But it doesn't seem to be doing any of that on my HW.

So what exactly is it supposed to do?


And on top of that, I am seeing random occurrences of

	nb8800 26000.ethernet eth0: Link is Down

Sometimes it is printed immediately.
Sometimes it is printed as soon as I run "ip link set dev eth0 up" (?!)
Sometimes it is not printed at all.

I find this erratic behavior very confusing.

Is it the symptom of some deeper bug?

Regards.
