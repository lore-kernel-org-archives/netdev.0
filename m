From: Andy Hawkins <adhawkins@gmail.com>
Subject: Re: Realtek 8169 based device
Date: Sat, 4 Feb 2012 15:03:51 +0000
Message-ID: <CAOkhdCcP3UqH3Dr9k8G5SzcA8OQr22XJ=KUa3hZfS2ZiioDORw@mail.gmail.com>
References: <CAOkhdCf-emWHJ0rB9GtC3MnX6oj3jgRAbYJU+q65GzMUdXmd-Q@mail.gmail.com>
	<201202031122.28949.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:42673 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2BDPDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 10:03:51 -0500
Received: by dadp15 with SMTP id p15so3531466dad.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 07:03:51 -0800 (PST)
In-Reply-To: <201202031122.28949.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Fri, Feb 3, 2012 at 10:22 AM, Ondrej Zary <linux@rainbow-software.org> wrote:
> Reseat the card in PCI slot. The difference between 0x106c (Hynix) and 0x10ec
> (Realtek) is only one bit, probably caused by a bad contact in the slot.

This turned out to be spot on.

There was a connector in line with the PCI slot (for front panel audio
ports) that was preventing the card from correctly sitting in the
slot. I unplugged this (don't use audio on this machine anyway) and
reseated the card, and it now works just fine.

Many thanks for the suggestion.

Andy
