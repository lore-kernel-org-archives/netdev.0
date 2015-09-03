From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 11:31:40 -0700
Message-ID: <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	<CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
	<20150903.104032.767889134756094076.davem@davemloft.net>
	<CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2015 at 11:22 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> [-Wsizeof-array-argument]

Ahh. Google shows that it's an old clang warning that gcc has recently
picked up.

But even clang doesn't seem to have any way for a project to say
"please warn about arrays in function argument declaration". It *is*
very traditional idiomatic C, it's just that I personally think it's
one of those bad traditional C things exactly because it's so
misleading about what actually goes on. But I guess that in practice,
the only thing that it actually *affects* is "sizeof" (and assignment
to the variable name - something that would be invalid for a real
array, but works on argument arrays because they are really just
pointers).

The "array as function argument" syntax is occasionally useful
(particularly for the multi-dimensional array case), so I very much
understand why it exists, I just think that in the kernel we'd be
better off with the rule that it's against our coding practices.

                  Linus
