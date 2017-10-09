From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] netlink: do not set cb_running if dump's start() errs
Date: Mon, 9 Oct 2017 14:12:11 +0200
Message-ID: <CAHmME9qK84HT6DEC2Z3q-E+J8AtNSp_7GNAcjWSSsKnxX0eAkA@mail.gmail.com>
References: <20171009115648.25989-1-Jason@zx2c4.com> <1507550326.26041.39.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507550326.26041.39.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

Yes, indeed, and I think that's actually a good thing. It means that
the starts aren't ever called in parallel, which could be useful if
drivers have any ordering requirements. The change doesn't negatively
effect any existing drivers. I'll resubmit with a larger commit
message explaining this.

Jason
