From: "Stefan Behte" <s.behte@babiel.com>
Subject: AW: AW: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 NIC no longer work with allow_unsupported_sfp=1
Date: Mon, 18 Feb 2013 18:38:25 +0100
Message-ID: <D76AF9B3DDF5FF49833AC0A1396549060314FC1B@s554.babiel.com>
References: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com> <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com> <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com> <146051361207312@web23e.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Oleg" <sysoleg@yandex.ru>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.babiel.com ([217.79.215.109]:38532 "EHLO mail.babiel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756484Ab3BRRi1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:38:27 -0500
Received: from localhost (unknown [127.0.0.1])
	by mail.babiel.com (Postfix) with ESMTP id 0172DB00179
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 17:38:26 +0000 (UTC)
Received: from mail.babiel.com ([127.0.0.1])
	by localhost (mail.babiel.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zi0vN354bntv for <netdev@vger.kernel.org>;
	Mon, 18 Feb 2013 18:38:25 +0100 (CET)
Received: from s554.babiel.com (business-178-015-110-066.static.arcor-ip.net [178.15.110.66])
	by mail.babiel.com (Postfix) with ESMTP id B9C29B00160
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 18:38:25 +0100 (CET)
Content-class: urn:content-classes:message
In-Reply-To: <146051361207312@web23e.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

printk("DEBUG comp_codes_1g: %u\n", comp_codes_1g);

results in:

=46eb 18 18:36:09 n128 kernel: [26043.714408] DEBUG comp_codes_1g: 2

Best regards,

Stefan Behte

-----Urspr=FCngliche Nachricht-----
Von: Oleg [mailto:sysoleg@yandex.ru]=20
Gesendet: Montag, 18. Februar 2013 18:09
An: Stefan Behte; Tantilov, Emil S; netdev@vger.kernel.org
Cc: Skidmore, Donald C; Kirsher, Jeffrey T; Fujinaka, Todd; Ronciak, Jo=
hn
Betreff: Re: AW: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/=
s X520 NIC no longer work with allow_unsupported_sfp=3D1



18.02.2013, 16:13, "Stefan Behte" <s.behte@babiel.com>:

>> 1. What is the SFP+ module you are using (make/model/type)?
>
> The module is a TP-Link TL-SM311LS 1000BASE-LX LC.

I've seen some transceivers that have "Code for electronic or
optical compatibility" EEPROM field (see SFF-8472) set to
all-zeroes. Maybe this is your case. Could you please printk
value of comp_codes_1g variable somewhere?

--=20
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
