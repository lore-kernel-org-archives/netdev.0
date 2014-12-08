From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 14:23:06 -0800
Message-ID: <CA+55aFz26Xvfs4iePpGgJotw+uwFCKduGqyM57adgfGepQYp_w@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208185635.GA25867@node.dhcp.inet.fi>
	<CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
	<20141208192358.GB25867@node.dhcp.inet.fi>
	<20141208221401.GA4991@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Theodore Ts'o" <tytso@mit.edu>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20141208221401.GA4991@thunk.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 8, 2014 at 2:14 PM, Theodore Ts'o <tytso@mit.edu> wrote:
>
> running trinity as root should be quite safe in a VM.  :-)

It's not so much the safety that I'd worry about, it's the "you can
legitimately just reboot it or cause kernel corruption as root". You
may not cause any problems outside of the VM, but any oopses inside
the VM might be due to trinity just doing bad things as root, rather
than kernel bugs..

Of course, it's probably hard to hit things like laoding random
modules etc, since even without signature requirements there are tons
of ELF sanity checks and other things. So it might be hard to actually
do those kinds of "corrupt kernel memory as root" things with trinity.

                 Linus
