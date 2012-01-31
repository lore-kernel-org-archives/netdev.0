From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 21:21:08 +0100
Message-ID: <4F284D34.9000602@broadcom.com>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com> <20120131192520.GA2974@tuxdriver.com>
 <20120131195822.GA2175@polaris.bitmath.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"=?ISO-8859-2?Q?Rafa=B3_M?= =?ISO-8859-2?Q?i=B3ecki?="
	<zajec5@gmail.com>, "Hauke Mehrtens" <hauke@hauke-m.de>
To: "Henrik Rydberg" <rydberg@euromail.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2770 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515Ab2AaUsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 15:48:04 -0500
In-Reply-To: <20120131195822.GA2175@polaris.bitmath.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2012 08:58 PM, Henrik Rydberg wrote:
>> From 1f3587dd7cdb8e2a505c76041bd5b816e7bcfb67 Mon Sep 17 00:00:00 2001
>> From: Henrik Rydberg <rydberg@euromail.se>
>> Date: Tue, 31 Jan 2012 14:22:15 -0500
>> Subject: [PATCH] bcma: don't fail for bad SPROM CRC
>>
>> If it is OK ...?
> 
> How about this:
> 
> The brcmsmac driver is now using the bcma SPROM logic, which does not
> recognize all chipsets that were functional prior to the switch. In
> particular, the current code bails out on odd CRC errors in recent
> Macbooks. This patch ignores those errors, with the argument that an
> unrecognized SPROM should be treated similarly to a non-existing one.
>

Not entirely correct. BCMA sprom logic is currently not used by
brcmsmac, but it sure (as hell) makes sense to do so. Currently, the
bcma SPROM logic is used in SoC chipsets (bcm47xx) and the b43 driver.

Gr. AvS
