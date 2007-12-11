From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.24-rc4-mm1
Date: Tue, 11 Dec 2007 13:59:42 -0800
Message-ID: <475F084E.3090309@intel.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>	<33307c790712110813h23def95dvd068b7226e9fcd36@mail.gmail.com> <20071211123705.844aac24.akpm@linux-foundation.org> <475F00A2.6020406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Martin Bligh <mbligh@google.com>, linux-kernel@vger.kernel.org,
	Andy Whitcroft <apw@shadowen.org>, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5141 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbXLKWB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 17:01:58 -0500
In-Reply-To: <475F00A2.6020406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Andrew Morton wrote:
>> On Tue, 11 Dec 2007 08:13:52 -0800 "Martin Bligh" <mbligh@google.com> wrote:
>>
>>>> - Lots of device IDs have been removed from the e1000 driver and moved
>>>> over
>>>>  to e1000e.  So if your e1000 stops working, you forgot to set
>>>> CONFIG_E1000E.
>>>>
>>>>
>>> Wouldn't it make sense to just default this to on if E1000 was on, rather
>>> than screwing
>>> everybody for no good reason (plus breaking all the automated testing, etc
>>> etc)?
>>> Much though I love random refactoring, it is fairly painful to just keep
>>> changing the
>>> names of things.
>> (cc netdev and Auke)
>>
>> Yes, that would be very sensible.  CONFIG_E1000E should default to whatever
>> CONFIG_E1000 was set to.
> 
> which is "y" for x86 and friends, ppc, arm and ia64 through 'defconfig'. the
> Kconfig files do not have defaults in them.
> 
> I can send a patch to adjust the defconfig files, would that be OK? I certainly
> think that would be reasonable, I dislike setting defaults through defconfig for
> network drivers myself and rather would not do that.

that should read "dislike setting defaults through Kconfig ..."

Auke
