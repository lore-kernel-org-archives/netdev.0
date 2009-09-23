From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 08:26:49 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909230755160.21515@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <200909221731.34717.agruen@suse.de> <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com> <200909230939.34003.tvrtko.ursulin@sophos.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:43064 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbZIWP0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 11:26:51 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S307919> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Wed, 23 Sep 2009 11:26:15 -0400
In-Reply-To: <200909230939.34003.tvrtko.ursulin@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2009, Tvrtko Ursulin wrote:

> Lived with it because there was no other option. We used LSM while it was 
> available for modules but then it was taken away. 
> 
> And not all vendors even use syscall interception, not even across platforms, 
> of which you sound so sure about. You can't even scan something which is not 
> in your namespace if you are at the syscall level. And you can't catch things 
> like kernel nfsd. No, syscall interception is not really appropriate at all.

Really?
And *if* namespaces were the problem for the devices you were targeting, 
what prevented you to resolving the object and offering a stream to 
userspace?
In *your* module, hosting at the same time all the other logic required 
for it (caches, whitelists, etc...), instead of pushing this stuff into 
the kernel.
WRT to the "other" system, never said they were using syscall 
interception, if you read carefully. I said that minifilters typically 
sends path names to userspace, which might drive you in the pitfall 
Andreas was describing.


- Davide


