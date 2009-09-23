From: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 16:45:28 +0100
Message-ID: <200909231645.29559.tvrtko.ursulin@sophos.com>
References: <20090912094110.GB24709@ioremap.net> <200909230939.34003.tvrtko.ursulin@sophos.com> <alpine.DEB.2.00.0909230755160.21515@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
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
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751974AbZIWPp3@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0909230755160.21515@makko.or.mcafeemobile.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 September 2009 16:26:49 Davide Libenzi wrote:
> On Wed, 23 Sep 2009, Tvrtko Ursulin wrote:
> > Lived with it because there was no other option. We used LSM while it was
> > available for modules but then it was taken away.
> >
> > And not all vendors even use syscall interception, not even across
> > platforms, of which you sound so sure about. You can't even scan
> > something which is not in your namespace if you are at the syscall level.
> > And you can't catch things like kernel nfsd. No, syscall interception is
> > not really appropriate at all.
>
> Really?
> And *if* namespaces were the problem for the devices you were targeting,
> what prevented you to resolving the object and offering a stream to
> userspace?

You are right, nothing really, we even do it like that today. But what about 
other interested users?

> In *your* module, hosting at the same time all the other logic required
> for it (caches, whitelists, etc...), instead of pushing this stuff into
> the kernel.
> WRT to the "other" system, never said they were using syscall
> interception, if you read carefully. I said that minifilters typically
> sends path names to userspace, which might drive you in the pitfall
> Andreas was describing.

Yeah, you could do something like kauth on OSX, which is I guess similar to 
LSM, which was turned off for out of tree. And now you want to push users of 
fanotify out of tree, so what should it be? In tree bad, out of tree bad? 

Tvrtko
