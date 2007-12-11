From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.24-rc4-mm1
Date: Tue, 11 Dec 2007 13:26:58 -0800
Message-ID: <475F00A2.6020406@intel.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>	<33307c790712110813h23def95dvd068b7226e9fcd36@mail.gmail.com> <20071211123705.844aac24.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Martin Bligh <mbligh@google.com>, linux-kernel@vger.kernel.org,
	Andy Whitcroft <apw@shadowen.org>, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754990AbXLKVaO@vger.kernel.org>
In-Reply-To: <20071211123705.844aac24.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Tue, 11 Dec 2007 08:13:52 -0800 "Martin Bligh" <mbligh@google.com> wrote:
> 
>>>
>>> - Lots of device IDs have been removed from the e1000 driver and moved
>>> over
>>>  to e1000e.  So if your e1000 stops working, you forgot to set
>>> CONFIG_E1000E.
>>>
>>>
>> Wouldn't it make sense to just default this to on if E1000 was on, rather
>> than screwing
>> everybody for no good reason (plus breaking all the automated testing, etc
>> etc)?
>> Much though I love random refactoring, it is fairly painful to just keep
>> changing the
>> names of things.
> 
> (cc netdev and Auke)
> 
> Yes, that would be very sensible.  CONFIG_E1000E should default to whatever
> CONFIG_E1000 was set to.

which is "y" for x86 and friends, ppc, arm and ia64 through 'defconfig'. the
Kconfig files do not have defaults in them.

I can send a patch to adjust the defconfig files, would that be OK? I certainly
think that would be reasonable, I dislike setting defaults through defconfig for
network drivers myself and rather would not do that.

Auke
