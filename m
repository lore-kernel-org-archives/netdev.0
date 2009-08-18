From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Tue, 18 Aug 2009 18:14:34 +0200
Message-ID: <20090818161434.GA15884@elte.hu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:54246 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233AbZHRQPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 12:15:07 -0400
Content-Disposition: inline
In-Reply-To: <4A8ACE1F.6020402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Gregory Haskins <gregory.haskins@gmail.com> wrote:

> > You haven't convinced me that your ideas are worth the effort 
> > of abandoning virtio/pci or maintaining both venet/vbus and 
> > virtio/pci.
> 
> With all due respect, I didnt ask you do to anything, especially 
> not abandon something you are happy with.
> 
> All I did was push guest drivers to LKML.  The code in question 
> is independent of KVM, and its proven to improve the experience 
> of using Linux as a platform.  There are people interested in 
> using them (by virtue of the number of people that have signed up 
> for the AlacrityVM list, and have mailed me privately about this 
> work).

This thread started because i asked you about your technical 
arguments why we'd want vbus instead of virtio. Your answer above 
now basically boils down to: "because I want it so, why dont you 
leave me alone".

What you are doing here is to in essence to fork KVM, regardless of 
the technical counter arguments given against such a fork and 
regardless of the ample opportunity given to you to demostrate the 
technical advantages of your code. (in which case KVM would happily 
migrate to your code)

We all love faster code and better management interfaces and tons 
of your prior patches got accepted by Avi. This time you didnt even 
_try_ to improve virtio. It's not like you posted a lot of virtio 
patches which were not applied. You didnt even try and you need to 
try _much_ harder than that before forking a project.

And fragmentation matters quite a bit. To Linux users, developers, 
administrators, packagers it's a big deal whether two overlapping 
pieces of functionality for the same thing exist within the same 
kernel. The kernel is not an anarchy where everyone can have their 
own sys_fork() version or their own sys_write() version. Would you 
want to have two dozen read() variants, sys_read_oracle() and a 
sys_read_db2()?

I certainly dont want that. Instead we (at great expense and work) 
try to reach the best technical solution. That means we throw away 
inferior code and adopt the better one. (with a reasonable 
migration period)

You are ignoring that principle with hand-waving about 'the 
community wants this'. I can assure you, users _DONT WANT_ split 
interfaces and incompatible drivers for the same thing. They want 
stuff that works well.

If the community wants this then why cannot you convince one of the 
most prominent representatives of that community, the KVM 
developers?

Furthermore, 99% of your work is KVM, why dont you respect that 
work by not forking it? Why dont you respect the KVM community and 
Linux in general by improving existing pieces of infrastructure 
instead of forcefully forking it?

	Ingo
