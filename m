From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Wed, 08 Sep 2010 08:55:18 +0200
Message-ID: <87wrqwiv1l.fsf@basil.nowhere.org>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
	<20100902065731.GB29972@elte.hu>
	<20100902100308.GA17167@basil.fritz.box>
	<20100903063934.GA25863@elte.hu> <1283888337.18468.9.camel@pjaxe>
	<4C869AA3.6000103@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Ingo Molnar <mingo@elte.hu>,
	"tglx\@linutronix.de" <tglx@linutronix.de>,
	"mingo\@redhat.com" <mingo@redhat.com>,
	"x86\@kernel.org" <x86@kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59101 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757323Ab0IHGzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 02:55:20 -0400
In-Reply-To: <4C869AA3.6000103@zytor.com> (H. Peter Anvin's message of "Tue,
	07 Sep 2010 13:03:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"H. Peter Anvin" <hpa@zytor.com> writes:
>
> If this is a production BIOS it should have this information.

The point was -- it wasn't a production BIOS and the production
BIOS will be fixed.

If you want you call fill the DMI tables with all bugs in preproduction
BIOS, but I suspect that will fill them up rather quickly. Preproduction
BIOS tend to be buggy (that is why they are pre-production)

Another problem also with adding stuff for early BIOS is that the later
BIOS likely have this fixed and then you have a quirk that runs but is
not needed (unless you add another DMI match for the fixed production
BIOS etc.) While for this case it would be probably harmless, 
this has caused problems in the past with other quirks.

Normally early users are also ok with having to specify an option
as a workaround, they just need something they can specify.

IMHO also it's good coding practice to have a command line option
for every DMI quirk anyways. This makes it easier to let 
users test if they need a particular quirk and helps
with users running older kernels.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
