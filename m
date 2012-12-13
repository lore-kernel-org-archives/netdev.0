From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Wed, 12 Dec 2012 21:27:34 -0500 (EST)
Message-ID: <20121212.212734.917363230032045212.davem@davemloft.net>
References: <20121212.151116.143443755590581447.davem@davemloft.net>
	<CA+55aFwzUgxQAze=mYbEx8b61V542tzm06Df=mR1BtYVbJy0mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwzUgxQAze=mYbEx8b61V542tzm06Df=mR1BtYVbJy0mg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 12 Dec 2012 18:15:04 -0800

> On Wed, Dec 12, 2012 at 12:11 PM, David Miller <davem@davemloft.net> wrote:
>>
>> There is one merge conflict to resolve in net/sched/cls_cgroup.c,
>> one commit changes the name of some members to "css_*" (this came
>> from Tejun's tree) and another commit adds an "attach" method.
> 
> There's more than that. The ARM board mess is apparently now affecting
> the networking merges too.
> 
> I fixed it up. Hopefully correctly.
> 
> Also, why does the new SHA1 hmac cookie support default to 'y'?

There are two SCTP HMAC cookie algorithms, MD5 and SHA1.

What used to happen is that you had to choose one at build
time, and then you were stuck with that decision and it was
all that you could use.

Now, it's selectable at run time.

If there's anything you find particularly anti-social about
this, I'm sure we can adjust it.
