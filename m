From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 15 Jul 2014 08:52:33 -0700
Message-ID: <CA+55aFw9=c_jSb7GOXDoityxWGiDs9y7LsdasyPHXESiZR75bg@mail.gmail.com>
References: <20140715.002844.679028486034873225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140715.002844.679028486034873225.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ugh, I wanted to point this out, since looking at the history it's
really ugly with silly extraneous merges for no good reason:

John, take a look at this:

On Tue, Jul 15, 2014 at 12:28 AM, David Miller <davem@davemloft.net> wrote:
>
> John W. Linville (7):
>       Merge git://git.kernel.org/.../jberg/mac80211
>       Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
>       Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
>       Merge branch 'ath-current' of git://github.com/kvalo/ath
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem
>       Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

and notice that there are two different kinds of merges in there. One
is the "merge from downstream developers" (good), but the other...

You're not the only one that does a "merge into for-upstream", but it
really is very noticeable in the resulting history. When David them
merges, you now get *two* merges, and the history is actually rather
less readable than it should/could be.

Maybe David has *asked* you to do this to resolve any merge conflicts
before sending it to him? I doubt it, though.

There's no reason for "merge into for-davem". Just send David that
thing you want merged. *Without* the extra merge. See what I'm saying?

This is the kind of thing I usually ask for from my direct pull
requests, for the same reason: it makes the history easier to see.
Merges should be down *by* upstream, not *for* upstream.

So those "into for-davem" merges are pointless and ugly.

And if David actually asks for these, my apologies..

                  Linus
