From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 08:35:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909230827100.21515@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <200909221731.34717.agruen@suse.de> <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com> <200909230939.34003.tvrtko.ursulin@sophos.com> <20090923112018.GA2946@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>,
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
	"alan@linux.intel.com" <alan@linux.intel.com>
To: "hch@infradead.org" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:33238 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbZIWPfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 11:35:25 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S307922> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Wed, 23 Sep 2009 11:34:40 -0400
In-Reply-To: <20090923112018.GA2946@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2009, hch@infradead.org wrote:

> On Wed, Sep 23, 2009 at 09:39:33AM +0100, Tvrtko Ursulin wrote:
> > Lived with it because there was no other option. We used LSM while it was 
> > available for modules but then it was taken away. 
> > 
> > And not all vendors even use syscall interception, not even across platforms, 
> > of which you sound so sure about. You can't even scan something which is not 
> > in your namespace if you are at the syscall level. And you can't catch things 
> > like kernel nfsd. No, syscall interception is not really appropriate at all.
> 
> The "Anti-Malware" industry is just snake oil anyway.  I think the
> proper approach to support it is just to add various no-op exports claim
> to do something and all the people requiring anti-virus on Linux will be
> just as happy with it.

The fear is that this becomes a trojan horse (no pun intended) for more 
and more hooks and "stuff", driven by we-really-need-this-too and 
we-really-need-that-too. And once something it's in, it's harder to say no, 
under the pressure of offering a "limited solution".
This ws the reason I threw the syscall tracing thing in, so they have a 
low level generic hook, and they cam knock themselves out in their module 
(might need a few exports, but that's about it).



- Davide


