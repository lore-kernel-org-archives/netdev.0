From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 21:23:58 +0200
Message-ID: <20141208192358.GB25867@node.dhcp.inet.fi>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208185635.GA25867@node.dhcp.inet.fi>
 <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 11:01:41AM -0800, Linus Torvalds wrote:
> On Mon, Dec 8, 2014 at 10:56 AM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> >
> > trinity triggers it for me in few minutes. I will try find out more once
> > get some time.
> 
> You run trinity as *root*?
> 
> You're a brave man. Stupid, but brave ;)
> 
> I guess you're running it in a VM, but still.. Doing random system
> calls as root sounds like a bad bad idea.

I'm doing this for a long time and didn't see any problem bigger than qemu
crash[1]. ;)

[1] http://thread.gmane.org/gmane.comp.emulators.qemu/194845/

-- 
 Kirill A. Shutemov
