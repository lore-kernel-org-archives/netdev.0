From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Wed, 08 Sep 2010 11:03:40 -0700
Message-ID: <4C87CFFC.8050709@zytor.com>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>	<20100902065731.GB29972@elte.hu>	<20100902100308.GA17167@basil.fritz.box>	<20100903063934.GA25863@elte.hu> <1283888337.18468.9.camel@pjaxe>	<4C869AA3.6000103@zytor.com> <87wrqwiv1l.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Ingo Molnar <mingo@elte.hu>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:46157 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752443Ab0IHSEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 14:04:13 -0400
In-Reply-To: <87wrqwiv1l.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2010 11:55 PM, Andi Kleen wrote:
> "H. Peter Anvin" <hpa@zytor.com> writes:
>>
>> If this is a production BIOS it should have this information.
> 
> The point was -- it wasn't a production BIOS and the production
> BIOS will be fixed.
> 

>From the original description:

This patch adds a boot parameter to allow a kernel to be booted
with the option to skip the SRAT check.  There are BIOSes in
                                         ^^^^^^^^^^^^^^^^^^^
production that have these failures, so this will allow people
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
in the field to work around these BIOS issues.


Agreed that command-line option is a good thing to have in general and
that it is not necessary to have DMI quirks for preproduction BIOSes.

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

