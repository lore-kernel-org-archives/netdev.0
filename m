From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] bcma: don't fail for bad SPROM CRC
Date: Mon, 6 Feb 2012 14:34:08 +0100
Message-ID: <4F2FD6D0.8070508@broadcom.com>
References: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?=" <zajec5@gmail.com>
To: "Henrik Rydberg" <rydberg@euromail.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4558 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222Ab2BFNez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 08:34:55 -0500
In-Reply-To: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 02:26 PM, Henrik Rydberg wrote:
> The brcmsmac driver is now checking the bcma SPROM CRCs, leaving some
> chipsets unrecognized that were functional prior to the switch. In
> particular, the current code bails out on recent Macbooks. This patch
> simply ignores the outcome of the CRC check, with the argument that an
> unrecognized SPROM should be treated similarly to a non-existing one.

Suggestion:

The brcmsmac driver is now registered as a bcma device driver. Some
chipsets fail on SPROM CRC check in the bcma bus driver. This leaves the
chipset unrecognized and the bcma bus is not registered so that brcmsmac
is not probed. In particular, the current code .......

Gr. AvS
