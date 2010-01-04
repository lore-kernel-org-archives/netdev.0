From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 10:40:47 -0800
Message-ID: <4B42362F.7040302@kernel.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org> <m1aawtlu6y.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:52926 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883Ab0ADSmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 13:42:31 -0500
In-Reply-To: <m1aawtlu6y.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2010 08:18 AM, Eric W. Biederman wrote:
> Yinghai Lu <yinghai@kernel.org> writes:
> 
> This patch is wrong.
> 
>> between FIRST_EXTERNAL_VECTOR (0x20) and FIRST_DEVICE_VECTOR (0x41)
>>
>> for 0x20 and 0x2f, we are safe be used_vectors will prevent it to use used one.
> 
> We can not use any of 0x20 - 0x2f for ioapic irqs.  We need the entire
> priority level to ensure that the irq move cleanup ipi is of a lower
> priority.
> 
>> also try to reuse 0x30 to 0x3f after smp_affinity for irq[0,15] is changed to other cpu.
> 
> There may be a point with 0x30 to 0x3f as I recall when those irqs come through a legacy
> pic we need to reserve those vectors on all cpus.

ok, I see.

any reason that we can not use 0x40?

Thanks

Yinghai
