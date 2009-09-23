From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 11:51:37 -0400
Message-ID: <1253721097.2890.3.camel@dhcp231-106.rdu.redhat.com>
References: <20090912094110.GB24709@ioremap.net>
	 <200909221731.34717.agruen@suse.de>
	 <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com>
	 <200909230939.34003.tvrtko.ursulin@sophos.com>
	 <20090923133232.5577688d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andreas Gruenbacher <agruen@suse.de>,
	Jamie Lokier <jamie@shareable.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"hch@infradead.org" <hch@infradead.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752618AbZIWPwB@vger.kernel.org>
In-Reply-To: <20090923133232.5577688d@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-09-23 at 13:32 +0200, Arjan van de Ven wrote:
> On Wed, 23 Sep 2009 09:39:33 +0100
> Tvrtko Ursulin <tvrtko.ursulin@sophos.com> wrote:
> 
> > Lived with it because there was no other option. We used LSM while it
> > was available for modules but then it was taken away. 
> 
> ... at which point you could have submitted your LSM module for
> inclusion... you'd be the first (and only?) Anti Virus vendor that
> would be in the mainline kernel.. speaking of competitive advantage,
> coming out of the box in all distributions.

And users would be left in a situation between choosing an LSM which
actually does in provable ways increase security and using an AV
scanner.  Until magic solves the LSM stacking problem (it's been tried,
no magic) I don't think any distro wants AV vendors as LSMs.

-Eric
