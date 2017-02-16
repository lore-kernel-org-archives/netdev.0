From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 15 Feb 2017 18:01:24 -0800
Message-ID: <CA+55aFz7UXOWaEDwMWGX8bbDKU_u4CnjAuRou-eSx2tCUBrH8w@mail.gmail.com>
References: <20170215.203136.1940941890600773041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215.203136.1940941890600773041.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 5:31 PM, David Miller <davem@davemloft.net> wrote:
>
> 3) More gracefully handle rhashtable insertion errors when vmalloc is
>    not possible, from Herbert Xu.

Ugh.

So I pulled this, but when I look at his code, I'm really not sure
that I should have, and I haven't pushed the result out. I'm pretty
sure I will unpull.

This code looks like it could *easily*  have subtle issues, and looks
like the kind of thing that should go in a merge window.

The merge commit has this re-assuring sentence in it from Herbert:

 "I've tested this with test_rhashtable and it appears to work."

and this is during the  very last week of an rc release.

None of the commits even talk about why this was needed in the first
place, so there's no indication that this new scary code was really so
high-priority that it absolutely *has* to go into a late rc release.
None of it is marked for stable either, since networking never does
that.

So David, you really need to convince me that this pull is truly required.

                Linus
