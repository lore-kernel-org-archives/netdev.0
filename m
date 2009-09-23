From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 10:31:26 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909231025120.22657@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <200909230939.34003.tvrtko.ursulin@sophos.com> <alpine.DEB.2.00.0909230755160.21515@makko.or.mcafeemobile.com> <200909231645.29559.tvrtko.ursulin@sophos.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Jamie Lokier <jamie@shareable.org>,
	Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"hch@infradead.org" <hch@infradead.org>
To: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200909231645.29559.tvrtko.ursulin@sophos.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Sep 2009, Tvrtko Ursulin wrote:

> Yeah, you could do something like kauth on OSX, which is I guess similar to 
> LSM, which was turned off for out of tree. And now you want to push users of 
> fanotify out of tree, so what should it be? In tree bad, out of tree bad? 

As I said before, the good of a syscall tracing approach, is that it is a 
completely generic mechanism (extensible for other kind of hooks too), 
with minimal kernel impact, while allowing its module-users to stuff all 
the code they want in the part that it's their responsibility.
So that a "we need this too" gets translated to "just do it in your code", 
instead of a request to add more stuff into the kernel, and maybe altering 
the userspace access interface (which is always painful).



- Davide


