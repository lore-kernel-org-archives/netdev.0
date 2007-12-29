From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Top 9 kernel oopses/warnings for the week of December 29th,
	2007
Date: Sat, 29 Dec 2007 14:17:12 +0100
Message-ID: <20071229131712.GB21805@elte.hu>
References: <477630CF.5070609@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755154AbXL2NRo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <477630CF.5070609@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Arjan van de Ven <arjan@linux.intel.com> wrote:

> kerneloops.org news:
>
> * As of 2.6.24-rc6, oopses have a unique identifier which makes it 
>   possible to filter out duplicate reports of (and replies to) the 
>   same oops. Unfortunately some reporters remove this line from their 
>   reports to lkml.

i'd not mind printing out the bootup-ID as a regular part of the oops, 
as long as it's put into an unintrusive place, preferably without adding 
a new line. (just use an empty spot somewhere)

for example:

Call Trace: (ID afbf0104e2079481)
 [<ffffffff805079f6>] sysdev_driver_unregister+0x5b/0x91
 [<ffffffff806f2ef4>] cpufreq_register_driver+0x15a/0x19b
 [<ffffffff80cb0586>] powernowk8_init+0x86/0x94

	Ingo
