From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Tue, 12 Aug 2008 08:46:41 +0800
Message-ID: <20080812004641.GB18444@gondor.apana.org.au>
References: <489DC15D.9070308@zytor.com> <20080809185224.GH13158@linux-os.sc.intel.com> <20080809193724.GJ13158@linux-os.sc.intel.com> <20080810030521.GA2332@gondor.apana.org.au> <20080811190131.GL13158@linux-os.sc.intel.com> <20080811192203.GC12788@elte.hu> <48A0920B.30306@zytor.com> <20080811201901.GN13158@linux-os.sc.intel.com> <20080812003938.GC18230@gondor.apana.org.au> <48A0DC6D.8040409@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Ingo Molnar <mingo@elte.hu>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33503 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751283AbYHLAq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:46:58 -0400
Content-Disposition: inline
In-Reply-To: <48A0DC6D.8040409@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 05:42:21PM -0700, H. Peter Anvin wrote:
>
> That's not sufficient, though, because you have to track all the state 
> and how it relates to everything.  You now have to track both the 
> userspace FPU state and the potential kernel FPU state.  The VIA 
> instructions are special (in the short bus to school sense) in that they 
> use a mechanism intended to protect specific state to protect -- exactly 
> nothing.

Sorry, the kernel TS state is what I meant.  I'm definitely not
advocating the saving of the kernel FPU state.  This is only for
things like the VIA (which also exists for other processors, see
the xor SSE stuff in include/asm-x86).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
