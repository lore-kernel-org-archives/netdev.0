From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Sat, 3 Jan 2015 10:07:33 -0800
Message-ID: <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
References: <1420297188.2397.3.camel@tiscali.nl>
	<CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul Bolle <pebolle@tiscali.nl>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Jiri Kosina <jkosina@suse.cz>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:63209 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbACSHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 13:07:34 -0500
In-Reply-To: <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 3, 2015 at 10:02 AM, Marcel Holtmann <marcel@holtmann.org> wrote:
>
> why would you revert this? It is obviously the correct change to actually select CFG80211_WEXT.

I don't know about obvious, but yeah, I think the select in this case
is actually the better idea anyway.

We could make the CFG80211_WEXT help message be very negative so that
people aren't encouraged to select it even if they can, but then if
they need the ipw driver it gets selected because of that. Because the
ipw driver is probably the more important of the two if you just
happen to have old hardware but are upgrading yout software (and
anybody who recompiles their own kernel is obviously doing the
latter).

                         Linus
