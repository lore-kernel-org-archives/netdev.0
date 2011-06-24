From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] ssb: use pci_dev->revision
Date: Fri, 24 Jun 2011 15:20:11 +0400
Message-ID: <4E0472EB.8060009@mvista.com>
References: <201106231849.53030.sshtylyov@ru.mvista.com>	<20110623170908.1417f933@maggie>	<4E0357BF.7000408@mvista.com> <20110623173204.00fbaed6@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGFlbCBCw7xzY2g=?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34706 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab1FXLVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 07:21:19 -0400
Received: by wyb38 with SMTP id 38so1852622wyb.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 04:21:17 -0700 (PDT)
In-Reply-To: <20110623173204.00fbaed6@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-06-2011 19:32, Michael B=C3=BCsch wrote:

>>>> The bus scan code reads PCI revision ID from the PCI configuration=
 register
>>>> while it's already stored by PCI subsystem in the 'revision' field=
 of 'struct
>>>> pci_dev'...

>>>> Signed-off-by: Sergei Shtylyov<sshtylyov@ru.mvista.com>

>>>> ---
>>>> The patch is against the recent Linus' tree.

>>>> There's another place where the revision ID register is read but a=
s 16-bit
>>>> entity (probably by mistake though), so I didn't convert it...

>>> Where is that?

>>      drivers/ssb/pci.c, line 741.

> Yes that probably is by mistake. Can you convert it as well, please?

    Tnen that whole function needs to be converted, as it reads subsyst=
rem ID=20
from the PCI config. space, while it's aready stored by PCI core. That =
is a=20
matter of yet another patch.

WBR, Sergei
