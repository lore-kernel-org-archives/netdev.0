From: Oleg <sysoleg@yandex.ru>
Subject: Re: AW: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 NIC no longer work with allow_unsupported_sfp=1
Date: Mon, 18 Feb 2013 21:08:32 +0400
Message-ID: <146051361207312@web23e.yandex.ru>
References: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com> <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com> <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Stefan Behte <s.behte@babiel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward9.mail.yandex.net ([77.88.61.48]:53517 "EHLO
	forward9.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016Ab3BRRQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:16:20 -0500
In-Reply-To: <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



18.02.2013, 16:13, "Stefan Behte" <s.behte@babiel.com>:

>> 1. What is the SFP+ module you are using (make/model/type)?
>
> The module is a TP-Link TL-SM311LS 1000BASE-LX LC.

I've seen some transceivers that have "Code for electronic or
optical compatibility" EEPROM field (see SFF-8472) set to
all-zeroes. Maybe this is your case. Could you please printk
value of comp_codes_1g variable somewhere?

-- 
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
