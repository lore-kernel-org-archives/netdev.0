From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 17:14:01 -0500
Message-ID: <20141208221401.GA4991@thunk.org>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208185635.GA25867@node.dhcp.inet.fi>
 <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
 <20141208192358.GB25867@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141208192358.GB25867@node.dhcp.inet.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 09:23:58PM +0200, Kirill A. Shutemov wrote:
> > I guess you're running it in a VM, but still.. Doing random system
> > calls as root sounds like a bad bad idea.
> 
> I'm doing this for a long time and didn't see any problem bigger than qemu
> crash[1]. ;)
> 
> [1] http://thread.gmane.org/gmane.comp.emulators.qemu/194845/

If you use something like this:

   -drive file=root_fs.img,if=virtio,snapshot=on

running trinity as root should be quite safe in a VM.  :-)

		   	       	  	- Ted
