From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 10:20:42 -0700
Message-ID: <4810C16A.3000606@zytor.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>	 <20080424112514.055d8071@the-village.bc.nu>	 <alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>	 <20080424.083908.147395158.davem@davemloft.net>	 <517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com>	 <20080424164226.415cedeb@the-village.bc.nu> <517f3f820804240948u788745f4s7a5dd4e7417ffeaf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"akpm@linux-foundation.org Jakub Jelinek" <jakub@redhat.com>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:34651 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbYDXRV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 13:21:27 -0400
In-Reply-To: <517f3f820804240948u788745f4s7a5dd4e7417ffeaf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Kerrisk wrote:
> On 4/24/08, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>>> But this approach fixes just one of the interfaces.  There are 7 or 8
>>  > other interfaces that need to solve the same problem.  What about
>>  > those?
>>
>>
>> Actually it seems to fix most of them.
> 
> Am I missingg something?  How?  There a number of system calls that
> have neither a flags argument, nor another argument that we can
> overload (as you propose with socket()).  For those, we'd need new
> system calls os sys_indirect().
> 

sys_indirect is a total red herring here, since it won't help one iota 
making the userspace interface comprehensible - it just introduces a 
different calling convention that the C library will have to thunk.

	-hpa
