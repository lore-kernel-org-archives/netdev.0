From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 10:34:32 -0700
Message-ID: <4810C4A8.1020505@zytor.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>	 <20080424112514.055d8071@the-village.bc.nu>	 <alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>	 <20080424.083908.147395158.davem@davemloft.net>	 <517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com>	 <20080424164226.415cedeb@the-village.bc.nu> <517f3f820804240948u788745f4s7a5dd4e7417ffeaf@mail.gmail.com> <4810C16A.3000606@zytor.com> <4810C3F1.9060009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	"akpm@linux-foundation.org Jakub Jelinek" <jakub@redhat.com>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:46314 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756040AbYDXRfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 13:35:44 -0400
In-Reply-To: <4810C3F1.9060009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ulrich Drepper wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> H. Peter Anvin wrote:
>> sys_indirect is a total red herring here, since it won't help one iota
>> making the userspace interface comprehensible - it just introduces a
>> different calling convention that the C library will have to thunk.
> 
> Nobody ever suggested that sys_indirect is in any way visible at the
> userlevel.  It's only meant to solve the problem of changing many
> syscalls (and hence touch lots of arch-specific code).  Again, as said
> several times, it could easily be used to fix the existing signalfd and
> eventfd syscalls without any arch-specific changes and no userlevel
> interface changes (the latter since we already have the correct interface).
> 
> Yes, you don't like sys_indirect, we know it.  But don't deliberately
> misrepresent the approach.
> 

I wasn't misrepresenting anything.  I was pointing out to the parent 
post -- not to you -- that sys_indirect does neither hide nor hair for 
what *he* was concerned about, which was the comprehensibility of the 
user-level interface.

	-hpa
