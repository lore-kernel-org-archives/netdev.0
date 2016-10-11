From: David Miller <davem@davemloft.net>
Subject: Re: slab corruption with current -git
Date: Tue, 11 Oct 2016 04:57:37 -0400 (EDT)
Message-ID: <20161011.045737.227906000874505402.davem@davemloft.net>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
        <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
        <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aconole@redhat.com, fw@strlen.de, viro@zeniv.linux.org.uk,
        akpm@linux-foundation.org, axboe@fb.com, tytso@mit.edu,
        cl@linux.com, pablo@netfilter.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Oct 2016 22:47:50 -0700

> On Mon, Oct 10, 2016 at 10:39 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> I guess I will have to double-check that the slub corruption is gone
>> still with that fixed.
> 
> So I'm not getting any warnings now from SLUB debugging. So the
> original bug seems to not have re-surfaced, and the registration bug
> is gone, so now the unregistration doesn't warn about anything either.
> 
> But I only rebooted three times.

Looks good to me, I applied it to my tree with your signoff and will
send you a pull request right now.

Thanks!
