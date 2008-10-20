From: "Pieter Steyn" <pieterste@gmail.com>
Subject: RE: 6040 Driver not working
Date: Mon, 20 Oct 2008 08:33:47 +0200
Message-ID: <c49e66200810192333u4b68dca7p9443d6b16657ff22@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: florian.fainelli@telecomint.eu
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:65251 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbYJTGdu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 02:33:50 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1837393fkq.5
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2008 23:33:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

=46orwarding this to netdev as per Florian's request.

Kind regards,

Pieter Steyn

=46orwarded conversation
Subject: r6040 driver not working.
------------------------

=46rom: Pieter Steyn <pieterste@gmail.com>
Date: Fri, Oct 17, 2008 at 4:50 PM
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: tech@dmp.com.tw


Hi,

I cannot get the r6040 driver working properly in either 2.6.26 or
2.6.27.  It compiles, and loads fine enough, but as soon as I try and
bring up the device I get a 'resource is in use and busy' message.

I've tried using both the driver supplied by the kernel and the one
linked on their website (with some modifications to make it compile :

r6040# diff r6040.c r6040.orig
277a278
>       SET_MODULE_OWNER(dev);
380c381
<       i =3D request_irq(dev->irq, &r6040_interrupt, IRQF_SHARED,
dev->name, dev);
---
>       i =3D request_irq(dev->irq, &r6040_interrupt, SA_SHIRQ, dev->na=
me, dev);
1079c1080
<       return pci_register_driver (&r6040_driver);
---
>       return pci_module_init (&r6040_driver);

Networking works with 2.6.21 using the driver from their website and
the above patch.

I've cc'ed in tech support to the manufacturer.

Thanks, and sorry if the information isn't much to work with...but
since I don't get any errors other than device being busy I'm not sure
what to do from here.

----------
=46rom: Pieter Steyn <pieterste@gmail.com>
Date: Fri, Oct 17, 2008 at 8:46 PM
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: tech@dmp.com.tw


Ugh, sorry.  I obviously meant the r6040 driver. :)

Cheers,
Pieter Steyn

----------
=46rom: Florian Fainelli <florian.fainelli@telecomint.eu>
Date: Sat, Oct 18, 2008 at 1:32 AM
To: Pieter Steyn <pieterste@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
tech@dmp.com.tw


Hi Pieter,

Le Friday 17 October 2008 20:46:46 Pieter Steyn, vous avez =E9crit :
I will debug this ASAP. Please CC netdev instead of linux-kernel as the
MAINTAINERS file indicates for this driver.
--
Cordialement, Florian Fainelli
