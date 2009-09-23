From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 07:20:19 -0400
Message-ID: <20090923112018.GA2946@infradead.org>
References: <20090912094110.GB24709@ioremap.net> <200909221731.34717.agruen@suse.de> <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com> <200909230939.34003.tvrtko.ursulin@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Andreas Gruenbacher <agruen@suse.de>,
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
Content-Disposition: inline
In-Reply-To: <200909230939.34003.tvrtko.ursulin@sophos.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2009 at 09:39:33AM +0100, Tvrtko Ursulin wrote:
> Lived with it because there was no other option. We used LSM while it was 
> available for modules but then it was taken away. 
> 
> And not all vendors even use syscall interception, not even across platforms, 
> of which you sound so sure about. You can't even scan something which is not 
> in your namespace if you are at the syscall level. And you can't catch things 
> like kernel nfsd. No, syscall interception is not really appropriate at all.

The "Anti-Malware" industry is just snake oil anyway.  I think the
proper approach to support it is just to add various no-op exports claim
to do something and all the people requiring anti-virus on Linux will be
just as happy with it.

