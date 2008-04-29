From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Tue, 29 Apr 2008 08:07:58 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904F9F13E@orsmsx414.amr.corp.intel.com>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> <20080429102107.GH23198@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <torvalds@linux-foundation.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48876 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754592AbYD2PH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 11:07:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080429102107.GH23198@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> * PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:
> 
> > This bug was introduced in the 2.6.24 i386/x86_64 tree merge, [...]
> 
> that's wrong, that code was there in v2.6.23 too - and it 
> wasnt touched in the unification. Why do you think it was 
> introduced in the
> i386/x86_64 tree merge?

2.6.23.17 didn't have the used_vectors bitmap.  The first time I could
find it used was in 2.6.24.  Where was the code existing in 2.6.23?  The
addition may have not been part of the merge, but it was definitely
introduced in the same timeframe, meaning the 2.6.24 release timeframe.

Cheers,
-PJ Waskiewicz
