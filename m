From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 15:08:25 +0100
Message-ID: <200912231508.25355.bzolnier@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <200912231407.20130.bzolnier@gmail.com> <4B321B9F.6030707@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:63071 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbZLWOKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:10:43 -0500
In-Reply-To: <4B321B9F.6030707@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 December 2009 02:31:11 pm Avi Kivity wrote:
> On 12/23/2009 03:07 PM, Bartlomiej Zolnierkiewicz wrote:
> >
> >> That is a very different situation from the AlacrityVM patches, which:
> >>
> >>   - Are a pure software concept and any compatibility mismatch is
> >>     self-inflicted. The patches are in fact breaking the ABI to KVM
> >>     intentionally (for better or worse).
> >>      
> > Care to explain the 'breakage' and why KVM is more special in this regard
> > than other parts of the kernel (where we don't keep any such requirements)?
> >    
> 
> The device model is exposed to the guest.  If you change it, the guest 
> breaks.

Huh?  Shouldn't non-vbus aware guests continue to work just fine?

> > I certainly missed the time when KVM became officially part of core ABI..
> >    
> 
> It's more akin to the hardware interface.  We don't change the hardware 
> underneath the guest.

As far as my limited understanding of things go vbus is completely opt-in
so it is like adding new real hardware to host.  Where is the problem?

--
Bartlomiej Zolnierkiewicz
