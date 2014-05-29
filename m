From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 0/8] cdc_ncm: fixes and conversion to sysfs API
Date: Thu, 29 May 2014 11:59:07 +0200
Message-ID: <87bnugdhxw.fsf@nemi.mork.no>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36639 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264AbaE2KAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 06:00:42 -0400
In-Reply-To: <1401101625-12342-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Mon, 26 May 2014 12:53:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> After considering the comments received after the ethtool coalesce
> support was commited, I have ended up concluding that we should
> remove it again, while we can, before it hits a release. The idea
> was not well enough thought through, and all comments received
> pointed to advantages of using a sysfs based API instead.
>
> This series removes the ethtool coalesce support and replaces it
> with sysfs attributes in a driver specific group under the netdev.

Hello David,

I see that this series is now marked "Not Applicable" in patchwork. But
the reason is not obvious to me.  May I ask why?

AFAICS, the series technically still applies to net-next, so I assume
the reason is that it is somehow inappropriate.  That's OK, but I do
assume some of it can be applied if split out from the rest?  It would
be good to have some hints about which parts I need to change or remove
for a possible resubmission.


Thanks,
Bj=C3=B8rn
