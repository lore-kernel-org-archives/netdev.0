From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2] isdn/gigaset: Convert timers to use timer_setup()
Date: Mon, 9 Oct 2017 10:36:14 -0700
Message-ID: <CAGXu5jKPm_KnLsS9Aj==r5fb7WCncFetKrbzdA4xkiW3ujx62Q@mail.gmail.com>
References: <20171005193118.GA105874@beast> <1507316433.6960.19.camel@tiscali.nl>
 <CAGXu5jJaMODs0NNasPY97wiXeQJ-Y5G+qLrFbwquhGJj=o3rxA@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD008D392@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paul Bolle <pebolle@tiscali.nl>,
        Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "gigaset307x-common@lists.sourceforge.net"
        <gigaset307x-common@lists.sourceforge.net>,
        Network Development <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008D392@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 9, 2017 at 2:15 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Kees Cook
>> Sent: 06 October 2017 20:40
> ...
>> I'm in no rush for any specific change. There are about 900 call sites
>> I'm making my way through, about 2/3rd are pretty trivial, and the
>> less obvious is what I've started sending out now, since I expect some
>> will need some more careful review.
>
> Is it worth adding a structure that contains a timer and an extra 'long'
> than can be used to maintain the existing API logic for the 'difficult'
> cases?

I didn't want to have this available in the general case, since I'd
like to get all the conversions actually finished. There are a couple
very special cases that need this, and they have one-off structs that
do this.

-Kees

-- 
Kees Cook
Pixel Security
