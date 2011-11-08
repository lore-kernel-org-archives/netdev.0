From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 1/2] net/smsc911x: Always wait for the chip to be ready
Date: Tue, 8 Nov 2011 11:34:01 +0100
Message-ID: <CAKnu2MoraoPsqBa9KSHHCG=8avrk_thdNEox1RUTRUGZKr14kA@mail.gmail.com>
References: <1319616343-6357-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64313 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab1KHKeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 05:34:02 -0500
Received: by wyh15 with SMTP id 15so308419wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 02:34:01 -0800 (PST)
In-Reply-To: <1319616343-6357-1-git-send-email-linus.walleij@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/26 Linus Walleij <linus.walleij@stericsson.com>:

> From: Robert Marklund <robert.marklund@stericsson.com>
>
> Wait for the chip to be ready before any access to it. On the
> Snowball platform we need to enable an external regulator before
> the chip comes online, and then it happens that the device is
> not yet ready at probe time, so let's wait for it.
>
> Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>

Since there doesn't seem to be any consternation concerning
this first patch, can it be applied?

Yours,
Linus Walleij
