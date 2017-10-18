From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aggregation: Convert timers to use
 timer_setup()
Date: Wed, 18 Oct 2017 13:31:31 +0200
Message-ID: <1508326291.2674.21.camel@sipsolutions.net>
References: <20171017202545.GA115810@beast>
         (sfid-20171017_222550_315925_34B26DDB) <1508322566.2674.17.camel@sipsolutions.net>
         (sfid-20171018_122945_123971_5A96CA64)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508322566.2674.17.camel@sipsolutions.net> (sfid-20171018_122945_123971_5A96CA64)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-18 at 12:29 +0200, Johannes Berg wrote:

> Anyway, the change here looks correct to me, so I'll apply it and then
> perhaps clean up more. I've only changed "u16 tid" to "u8 tid" since
> the valid range is 0-15 (in theory, in practice 0-7).

Well, I guess I'm clearly wrong - it's crashing our test suite left and
right.

I'll dig a little bit, but I don't have much time today, and will be
out for a few days starting tomorrow.

johannes
