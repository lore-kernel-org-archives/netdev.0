From: Maxim Osipov <maxim.osipov@gmail.com>
Subject: =?KOI8-R?Q?Re=3A_=EF=D4=D7=C5=D4=3A_=5BPATCH_10=2F10=5D_ieee802154=3A_add_at86rf?=
	=?KOI8-R?Q?230=2Frf231_spi_driver?=
Date: Tue, 2 Jun 2009 12:49:36 +0400
Message-ID: <6097c490906020149j5d614064ied2a4bfebd13ddb0@mail.gmail.com>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	 <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com>
	 <20090601203348.GC7143@doriath.ww600.siemens.net>
	 <200906021010.49613.hs4233@mail.mn-solutions.de>
	 <1243930893.3192.62.camel@localhost.localdomain>
	 <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com>
	 <1243931809.3192.68.camel@localhost.localdomain>
Reply-To: maxim@mox.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Holger Schurig <hs4233@mail.mn-solutions.de>,
	linux-wireless@vger.kernel.org,
	=?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:44431 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340AbZFBIzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 04:55:31 -0400
In-Reply-To: <1243931809.3192.68.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel,

On Tue, Jun 2, 2009 at 12:36 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
>> For Bluetooth naming directories 'bluetooth' is logical, as 802.15.1
>> standard is a less known name, doesn't incorporate latest changes
>> from Bluetooth, etc.
>
> and so is IEEE 802.15.4 hence we propose using "zigbee" here. Using the
> mac80211 has historical reasons and 802.11 is a known name and even used
> on product marketing material. IEEE 802.15.4 is not. We are also using
> the term "wimax" and not its IEEE numbering.

Actually, ieee802154 is better in this case, because as Dmitry
mentioned, an entire family of standards is implemented on the top of
it, including:

- ZigBee
- 6LoWPAN
- ISA100.11a
- WirelessHART
 - and probably something I don't know about

All of them (once implemented) will use ieee802.15.4 drivers. It is
better to avoid future confusion and use correct terminology from the
very beginning.

Kind regards,
Maxim
