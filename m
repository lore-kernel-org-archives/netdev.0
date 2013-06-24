From: Andrew Brooks <arb@sat.dundee.ac.uk>
Subject: Re: niu lock-up (Transmit timed out, resetting) and NETDEV WATCHDOG
Date: Mon, 24 Jun 2013 11:20:15 +0100
Message-ID: <CAHOfOo0kdByd3T0LL4tBpy-aFtJS6bRK7D=rPc6Si0iv03CLKQ@mail.gmail.com>
References: <CAHOfOo21+hSwFrXZuoMppcivcOonhx-m1p-yyZsm6c5UCh0joQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Net-Dev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:53620 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab3FXKUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 06:20:36 -0400
Received: by mail-ie0-f178.google.com with SMTP id u16so23394781iet.23
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 03:20:35 -0700 (PDT)
In-Reply-To: <CAHOfOo21+hSwFrXZuoMppcivcOonhx-m1p-yyZsm6c5UCh0joQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 March 2013 13:44, Andrew Brooks <arb@sat.dundee.ac.uk> wrote:
>
> Using niu driver for this card: Oracle/SUN Multithreaded 10-Gigabit
> Ethernet Network Controller and after a period the interface will hang
> with errors every 5 seconds
> "niu: xxx: eth2: Transmit timed out, resetting"
>
> Sometimes also in syslog are messages
> WARNING: at sch_generic:255 dev_watchdog
> NETDEV WATCHDOG: eth2 (niu): transmit queue 10 timed out

Do you think this could be caused by a problem I've seen reported
by other machines on the network
"received unsolicited ack for DL_UNITDATA_REQ on nxge0" ?
Is there some bad packet flying around that causes the
niu driver to lock up the kernel?
