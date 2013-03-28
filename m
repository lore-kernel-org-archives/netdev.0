From: Andrew Brooks <arb@sat.dundee.ac.uk>
Subject: Re: niu lock-up (Transmit timed out, resetting) and NETDEV WATCHDOG
Date: Thu, 28 Mar 2013 14:52:02 +0000
Message-ID: <CAHOfOo0m8JQQgzsyq9V9-63oN6SFz8Rudo-h5VMQGnWt31CCFg@mail.gmail.com>
References: <CAHOfOo21+hSwFrXZuoMppcivcOonhx-m1p-yyZsm6c5UCh0joQ@mail.gmail.com>
 <CAHOfOo3EZKWJuEGN3wxW9RBb_YXjLxv-DgCULrO=TPTuLSQcdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Net-Dev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:43890 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756632Ab3C1OwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 10:52:25 -0400
Received: by mail-ia0-f170.google.com with SMTP id h8so8499669iaa.29
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 07:52:23 -0700 (PDT)
In-Reply-To: <CAHOfOo3EZKWJuEGN3wxW9RBb_YXjLxv-DgCULrO=TPTuLSQcdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks

This is a show-stopper. Does anyone have any ideas?

Thanks!

On 26 March 2013 13:46, Andrew Brooks <arb@sat.dundee.ac.uk> wrote:
>
> Hello
>
> Using niu driver for this card: Oracle/SUN Multithreaded 10-Gigabit
> Ethernet Network Controller
> after a period (often less than 24 hours) the interface will hang with
> errors every 5 seconds
> "niu: xxx: eth2: Transmit timed out, resetting"
>
> Sometimes also in syslog are messages
> WARNING: at sch_generic:255 dev_watchdog
> NETDEV WATCHDOG: eth2 (niu): transmit queue 10 timed out
>
> I've seen this in kernel 3.5.0-26-generic #42~precise1-Ubuntu SMP
> but I've not seen it in kernel 3.2.0-38-generic #61-Ubuntu SMP
>
> Is there some change between kernels which has broken the driver
> or is the difference elsewhere?
