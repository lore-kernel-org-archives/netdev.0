From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: pull-request: mac80211 2017-10-16
Date: Tue, 17 Oct 2017 01:30:31 +0200
Message-ID: <CAHmME9rHMMAgJs3uQYpt15V8eh-PjDqioqURA3KPKEhc2a9OEg@mail.gmail.com>
References: <20171016134618.30810-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:48901 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932361AbdJPXaf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 19:30:35 -0400
In-Reply-To: <20171016134618.30810-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mobile phone right now, so not able to write patch, but you probably
should be using crypto_memneq for comparing those two keys, not
memcmp.

Jason
