From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 11:45:53 -0800
Message-ID: <1262634353.2700.49.camel@sbs-t61.sc.intel.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	 <4B398ECD.1080506@kernel.org>
	 <4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
	 <4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>
	 <m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>
	 <m1my0thelq.fsf@fess.ebiederm.org>  <4B424305.7050803@kernel.org>
Reply-To: Suresh Siddha <suresh.b.siddha@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39042 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960Ab0ADTrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 14:47:11 -0500
In-Reply-To: <4B424305.7050803@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-04 at 11:35 -0800, Yinghai Lu wrote:
> sth like this?
> 
> Subject: [PATCH 1/2] x86: get back 16 vectors
> 
> -v2: according to hpa that we could start from 0x10
>      according to Eric, we should hold 16 vectors for IRQ MOVE
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> 

Yinghai we have to change IRQ_MOVE_CLEANUP_VECTOR to 0x1f or so. From
the cpu perspective this vector is documented as illegal, so we need to
check if this change will work on the cpu's we have today to get some
confidence.

thanks,
suresh

