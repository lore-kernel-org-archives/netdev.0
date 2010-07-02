From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [net-next-2.6 PATCH] x86: Drop CONFIG_MCORE2 check around setting
 of	NET_IP_ALIGN
Date: Thu, 01 Jul 2010 18:15:13 -0700
Message-ID: <4C2D3DA1.8040303@zytor.com>
References: <20100701232742.15934.49030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Andi Kleen <ak@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, x86@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:57086 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570Ab0GBBPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 21:15:40 -0400
In-Reply-To: <20100701232742.15934.49030.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2010 04:28 PM, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch removes the CONFIG_MCORE2 check from around NET_IP_ALIGN.  It is
> based on a suggestion from Andi Kleen.  The assumption is that there are
> not any x86 cores where unaligned access is really slow, and this change
> would allow for a performance improvement to still exist on configurations
> that are not necessarily optimized for Core 2.
> 
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: H. Peter Anvin <hpa@zytor.com>

	-hpa
