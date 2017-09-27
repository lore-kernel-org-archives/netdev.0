From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] netlink: do not proceed if dump's start() errs
Date: Wed, 27 Sep 2017 15:06:40 +0200
Message-ID: <CAHmME9oA+dE3eOCTWweJjZGL4sog30JShoCJoWaPn4JV7h3auA@mail.gmail.com>
References: <20170927123915.5779-1-Jason@zx2c4.com> <CAHmME9pUWenvkMCNkAHa6K71UDdETvriMr52sKPL38q19M3RVw@mail.gmail.com>
 <1506517514.2108.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1506517514.2108.2.camel@sipsolutions.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 3:05 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> I guess you could change it to
>
> if (cb->start)
>         ret = cb->start(cb);
> if (!ret)
>         ret = netlink_dump(sk);

Very clean. I'll do it like that. I'll wait a bit longer before
submitting v2, but beyond that, seems sane to you?

Jason
