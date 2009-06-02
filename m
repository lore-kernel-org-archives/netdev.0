From: Jonathan Cameron <jic23@cam.ac.uk>
Subject: Re: =?windows-1252?Q?=3F=3F=3F=3F=3F=3A_=5BPATCH_10/10=5D_?=
 =?windows-1252?Q?ieee802154=3A_add_at86rf230/rf231_spi_driver?=
Date: Tue, 02 Jun 2009 09:29:42 +0000
Message-ID: <4A24F106.5040704@cam.ac.uk>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>	 <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com>	 <20090601203348.GC7143@doriath.ww600.siemens.net>	 <200906021010.49613.hs4233@mail.mn-solutions.de>	 <1243930893.3192.62.camel@localhost.localdomain>	 <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com>	 <1243931809.3192.68.camel@localhost.localdomain> <6097c490906020149j5d614064ied2a4bfebd13ddb0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Holger Schurig <hs4233@mail.mn-solutions.de>,
	linux-wireless@vger.kernel.org,
	=?windows-1252?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com
To: maxim@mox.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-5.csi.cam.ac.uk ([131.111.8.135]:34536 "EHLO
	ppsw-5.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbZFBJ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:29:36 -0400
In-Reply-To: <6097c490906020149j5d614064ied2a4bfebd13ddb0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Osipov wrote:
> Hi Marcel,
> 
> On Tue, Jun 2, 2009 at 12:36 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
>>> For Bluetooth naming directories 'bluetooth' is logical, as 802.15.1
>>> standard is a less known name, doesn't incorporate latest changes
>>> from Bluetooth, etc.
>> and so is IEEE 802.15.4 hence we propose using "zigbee" here. Using the
>> mac80211 has historical reasons and 802.11 is a known name and even used
>> on product marketing material. IEEE 802.15.4 is not. We are also using
>> the term "wimax" and not its IEEE numbering.
> 
> Actually, ieee802154 is better in this case, because as Dmitry
> mentioned, an entire family of standards is implemented on the top of
> it, including:
> 
> - ZigBee
> - 6LoWPAN
> - ISA100.11a
> - WirelessHART
>  - and probably something I don't know about
I'll tack on tosmac (the tinyos protocol).
The platforms I support have out of kernel support for a cc2420 (802.15.4) radio
using that protocol. In the embedded sensors field it seems to be
pretty common to use linux nodes as gateways to systems running various realtime
/ light weight OSes.

As Maxim stated there are a lot of protocols out there.

Thank you to Dmitry and co for your work on this project, I'll be following
your progress with interest (and when I have a sec adding support for the cc2420
if no one else does it first ;)

---
Jonathan Cameron

 
