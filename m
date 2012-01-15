From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Sun, 15 Jan 2012 11:02:23 +0100
Message-ID: <1326621743.3448.1.camel@jlt3.sipsolutions.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	 (sfid-20120114_162556_888923_085E9D1A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37176 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab2AOKC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2012 05:02:27 -0500
In-Reply-To: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com> (sfid-20120114_162556_888923_085E9D1A)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kay,

> These drivers need to be fixed to load their firmware during ifup,
> which would be the most flexible solution. That way, it should also
> work if the driver is built-in, or is loaded from initramfs and no
> firmware is available.
> Alternatively, the firmware request should be able to use the aync
> firmware_request API and not the blocking one.

Will udev now also return the async load only after root is booted if it
can't be satisfied earlier? There are a number of devices, particularly
wireless, that need firmware before they can register with mac80211 for
capability advertisement reasons.

johannes
