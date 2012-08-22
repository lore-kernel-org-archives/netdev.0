From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/3] x86_64, sfc: 128-bit memory-mapped I/O
Date: Tue, 21 Aug 2012 18:38:24 -0700
Message-ID: <50343810.2000809@zytor.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:36996 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab2HVBil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 21:38:41 -0400
In-Reply-To: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 06:17 PM, Ben Hutchings wrote:
> Current Solarflare network controllers have 128-bit memory-mapped
> registers which are normally accessed through a series of I/O
> operations.  However, it is also possible to access them with a single
> MOVAPS instruction on x86_64, and this is measurably faster as it
> requires only one PCIe transaction.

Also, have you considered doing this with write combining instead?

	-hpa
