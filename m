From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] ssb: use pci_dev->revision
Date: Thu, 23 Jun 2011 19:11:59 +0400
Message-ID: <4E0357BF.7000408@mvista.com>
References: <201106231849.53030.sshtylyov@ru.mvista.com> <20110623170908.1417f933@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Michael_B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41077 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758347Ab1FWPNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 11:13:46 -0400
Received: by wyb38 with SMTP id 38so1351357wyb.19
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 08:13:44 -0700 (PDT)
In-Reply-To: <20110623170908.1417f933@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Michael B=FCsch wrote:

>> The bus scan code reads PCI revision ID from the PCI configuration r=
egister
>> while it's already stored by PCI subsystem in the 'revision' field o=
f 'struct
>> pci_dev'...

>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

>> ---
>> The patch is against the recent Linus' tree.

>> There's another place where the revision ID register is read but as =
16-bit
>> entity (probably by mistake though), so I didn't convert it...

> Where is that?

    drivers/ssb/pci.c, line 741.

WBR, Sergei

