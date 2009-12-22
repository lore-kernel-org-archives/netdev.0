From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 17:01:56 +0100
Message-ID: <200912221701.56840.bzolnier@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753910AbZLVQE7@vger.kernel.org>
In-Reply-To: <4B30E654.40702@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 December 2009 04:31:32 pm Anthony Liguori wrote:

> I think the comparison would be if someone submitted a second e1000 
> driver that happened to do better on one netperf test than the current 
> e1000 driver.
> 
> You can argue, hey, choice is good, let's let a user choose if they want 
> to use the faster e1000 driver.  But surely, the best thing for a user 
> is to figure out why the second e1000 driver is better on that one test, 
> integrate that change into the current e1000 driver, or decided that the 

Even though this is "Won't somebody please think of the users?" argument
such work would be much welcomed.  Sending patches would be a great start..

> new e1000 driver is more superior in architecture and do the required 
> work to make the new e1000 driver a full replacement for the old one.

Right, like everyone actually does things this way..

I wonder why do we have OSS, old Firewire and IDE stacks still around then?

> Regards,
> 
> Anthony Liguori
> 
> > Unwritten code tends to always sound nicer, but it remains to be seen
> > if it can deliver what it promises.
> >
> >  From a abstract stand point having efficient paravirtual IO interfaces
> > seem attractive.
> >
> > I also personally don't see a big problem in having another set of
> > virtual drivers -- Linux already has plenty (vmware, xen, virtio, power,
> > s390-vm, ...) and it's not that they would be a particular maintenance
> > burden impacting the kernel core.

Exactly, I also don't see any problem here, especially since AlacrityVM
drivers have much cleaner design / internal architecture than some of their
competitors..

--
Bartlomiej Zolnierkiewicz
