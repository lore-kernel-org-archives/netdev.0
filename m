From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 05:19:01 -0700
Message-ID: <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
References: <1319764761.23112.14.camel@edumazet-laptop> <20111028012521.GF25795@one.firstfloor.org>
 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
 <1319766293.6759.17.camel@deadeye> <1319770376.23112.58.camel@edumazet-laptop>
 <1319772566.6759.27.camel@deadeye> <1319777025.23112.67.camel@edumazet-laptop>
 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com> <1319803781.23112.113.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319803781.23112.113.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2011 at 5:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> What you describe is true for non atomic variables as well, its not part
> of the atomic_ops documented semantic.

Eric - your "documentation" is so much toilet paper. So don't bother
talkign about "documented semantics". Start talking about SANE
INTERFACES.

What I described is very much true of non-atomics. Nobody doubts that.

THE QUESTION IS WHETHER IT MAKES SENSE FOR ATOMICS, DAMMIT!

And quite frankly, the behavior I described does not seem to make any
sense for atomics.

"Sane interfaces" are important. Insane interfaces lead to bugs.

                      Linus
