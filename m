From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 14:07:46 -0600
Message-ID: <473A0412.4030005__42308.968693442$1194984529$gmane$org@lwfinger.net>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com> <20071113171356.GA25824@thunk.org> <4739DFF8.3090702@lwfinger.net> <20071113185547.GC25824@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Theodore Tso <tytso@mit.edu>,
	Larry Finger <larry.finger@lwfinger.net>,
	Benoit Boissinot <bboissin@gmail.com>, Mark Lord <liml@rtr.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <ak
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:35154 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753663AbXKMUIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 15:08:12 -0500
In-Reply-To: <20071113185547.GC25824@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Theodore Tso wrote:
> 
> Heh. I hadn't enabled CONFIG_BCM43XX_DEBUG myself, but I just changed
> it for my next kernel build.  This is a slightly different issue,
> which is that sometimes _DEBUG options shouldn't be turned on by
> default (because they really trash performance and bloat log size),
> and sometimes they are painless to turn on and don't cost much.
> 
> If that is the case, I'd suggest removing the option and just making
> it compiled in by default with a run-time option to enable it.

I am taking your suggestion and will produce the necessary patches for ssb, b43 and b43legacy. As
bcm43xx is likely to be removed from 2.6.25, which is the earliest such a non-bug fix patch would be
accepted, I hope that your future distribution and testing kernels will include the debug option.

Thanks,

Larry
