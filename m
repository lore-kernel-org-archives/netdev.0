From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Mon, 11 Aug 2008 15:57:09 -0700
Message-ID: <20080811225709.GO13158@linux-os.sc.intel.com>
References: <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809003829.GA25926@gondor.apana.org.au> <20080809142918.GA30387@gondor.apana.org.au> <20080809143259.GA30451@gondor.apana.org.au> <20080809175247.GD13158@linux-os.sc.intel.com> <20080810053048.GA3171@gondor.apana.org.au> <489E7F9C.9000708@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>,
	austin zhang <austin_zhang@linux.intel.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3696 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbYHKW5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 18:57:11 -0400
Content-Disposition: inline
In-Reply-To: <489E7F9C.9000708@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 10:41:48PM -0700, H. Peter Anvin wrote:
> Herbert Xu wrote:
> > On Sat, Aug 09, 2008 at 10:52:48AM -0700, Suresh Siddha wrote:
> >>> Actually I was mistaken, Intel has done the right thing by not
> >>> generating a fault on crc32c with TS set.
> >> Yes, the documentation seems to says so. But I am double checking
> >> with experts inside, to make sure we got the SDM right.

I got confirmation that crc32 instructions don't generate DNA when cr0.TS bit
is set. So no changes required for Austin's patches in this context.

thanks,
suresh
