From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for
 sockets in accept(3)
Date: Sun, 1 Nov 2015 16:59:23 -0800
Message-ID: <CA+55aFwyFPdw3b=Cd+T7=iO+Dc4BkybMJnV+HT5AJRntUb=jhQ@mail.gmail.com>
References: <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	<20151030210215.GI22011@ZenIV.linux.org.uk>
	<CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	<CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	<20151030223317.GK22011@ZenIV.linux.org.uk>
	<CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
	<20151031193449.GM22011@ZenIV.linux.org.uk>
	<CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
	<20151031202929.GN22011@ZenIV.linux.org.uk>
	<20151102002421.GP22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20151102002421.GP22011@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 1, 2015 at 4:24 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> This ought to be a bit cleaner.  Eric, could you test the variant below on your
> setup?

I'd love to see the numbers, but at the same time I really can't say I
love your patch.

I've merged my own two patches for now (not actually pushed out - I
don't want to distract people from just testing 4.3 for a while),
because I felt that those had a unreasonably high bang-for-the-buck
(ie big speedups for something that still keeps the code very simple).

I'm definitely open to improving this further, even go as far as your
patch, but just looking at your version of __alloc_fd(), I just don't
get the warm and fuzzies.

                  Linus
