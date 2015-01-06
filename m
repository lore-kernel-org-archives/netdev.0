From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Tue, 06 Jan 2015 14:26:45 +0100
Message-ID: <1420550805.1966.30.camel@sipsolutions.net>
References: <1420297188.2397.3.camel@tiscali.nl>
	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
	 <1420324124.9624.60.camel@x220> <54AA641C.7050307@broadcom.com>
	 <1420479510.14308.23.camel@x220>
	 (sfid-20150105_183907_807502_81C08416) <1420484224.9459.16.camel@sipsolutions.net>
	 <1420495519.14308.29.camel@x220> <1420532617.1966.2.camel@sipsolutions.net>
	 (sfid-20150106_092406_190634_68A6D76E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Jiri Kosina <jkosina@suse.cz>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59612 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445AbbAFN0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 08:26:53 -0500
In-Reply-To: <1420532617.1966.2.camel@sipsolutions.net> (sfid-20150106_092406_190634_68A6D76E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-06 at 09:23 +0100, Johannes Berg wrote:

> Yours is the theoretical, hopefully-forward-looking one where we still
> expect the driver to actually be modified to take advantage of the new
> frameworks (which is independent of wext support towards userspace). In
> that scenario, yes, it should use more until it uses all, and then it
> can stop concerning itself with wext (which would be a win because
> driver/wext interaction is always finicky) (*)

I just realized that in order to actually do this you'd have to revert
04b0c5c6995103eef56391c163e970ab1f03b59f first, but that would be pretty
simple.

johannes
