From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Wed, 19 Oct 2016 08:59:09 -0700
Message-ID: <5807984D.4050307@candelatech.com>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org> <1476689310.19992.1.camel@sipsolutions.net> <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com> <CALCETrUWW2A1XK7BzcajTcBzg58SDUCTE35Hj1vmbywTLCe2vQ@mail.gmail.com> <CAKv+Gu-25OvTSbyE06Ln8N+HsqNyV1T6oOudK2tyAAOmmXXqgA@mail.gmail.com> <20161019033157.GA1457@gondor.apana.org.au> <1476862995.5927.3.camel@sipsolutions.net> <CAKv+Gu9CppR+AN5_RdDJ6ZBRr1EDDLB+nABPddyaj5TKb5=j_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKv+Gu9CppR+AN5_RdDJ6ZBRr1EDDLB+nABPddyaj5TKb5=j_Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/19/2016 08:08 AM, Ard Biesheuvel wrote:
> On 19 October 2016 at 08:43, Johannes Berg <johannes@sipsolutions.net> wrote:
>> On Wed, 2016-10-19 at 11:31 +0800, Herbert Xu wrote:

>> We could probably make mac80211 do that too, but can we guarantee in-
>> order processing? Anyway, it's pretty low priority, maybe never
>> happening, since hardly anyone really uses "software" crypto, the wifi
>> devices mostly have it built in anyway.
>>
>
> Indeed. The code is now correct in terms of API requirements, so let's
> just wait for someone to complain about any performance regressions.

Do you actually expect performance regressions?  I'll be complaining if
so, but will test first :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
