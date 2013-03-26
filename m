From: Andrew Brooks <arb@sat.dundee.ac.uk>
Subject: niu lock-up (Transmit timed out, resetting) and NETDEV WATCHDOG
Date: Tue, 26 Mar 2013 13:46:25 +0000
Message-ID: <CAHOfOo3EZKWJuEGN3wxW9RBb_YXjLxv-DgCULrO=TPTuLSQcdA@mail.gmail.com>
References: <CAHOfOo21+hSwFrXZuoMppcivcOonhx-m1p-yyZsm6c5UCh0joQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Net-Dev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:60084 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934428Ab3CZNqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 09:46:46 -0400
Received: by mail-ie0-f180.google.com with SMTP id a11so8762745iee.11
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 06:46:45 -0700 (PDT)
In-Reply-To: <CAHOfOo21+hSwFrXZuoMppcivcOonhx-m1p-yyZsm6c5UCh0joQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Using niu driver for this card: Oracle/SUN Multithreaded 10-Gigabit
Ethernet Network Controller
after a period (often less than 24 hours) the interface will hang with
errors every 5 seconds
"niu: xxx: eth2: Transmit timed out, resetting"

Sometimes also in syslog are messages
WARNING: at sch_generic:255 dev_watchdog
NETDEV WATCHDOG: eth2 (niu): transmit queue 10 timed out

I've seen this in kernel 3.5.0-26-generic #42~precise1-Ubuntu SMP
but I've not seen it in kernel 3.2.0-38-generic #61-Ubuntu SMP

Is there some change between kernels which has broken the driver
or is the difference elsewhere?

Thanks

Andrew
