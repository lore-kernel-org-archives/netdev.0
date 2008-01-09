From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Wed, 09 Jan 2008 07:28:40 -0800
Message-ID: <4784E828.7090906@linux.intel.com>
References: <477FF149.4070609@linux.intel.com>	 (sfid-20080105_210825_521052_738F2802) <1199887950.6762.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755634AbYAIPlG@vger.kernel.org>
In-Reply-To: <1199887950.6762.26.camel@johannes.berg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
>> Rank 1: __ieee80211_rx
>> 	Warning at net/mac80211/rx.c:1672
>> 	Reported 6 times (11 total reports)
>> 	Same issue that was ranked 2nd last week
>> 	Johannes has diagnosed this as a driver bug in the iwlwifi drivers
>> 	More info: http://www.kerneloops.org/search.php?search=__ieee80211_rx
> 
> Note that because we don't get the module list for WARN_ON, we don't
> actually know whether all of these instances are from the iwlwifi
> drivers. A few other drivers suffer from the same problem. In one of
> these cases, iwlwifi was contained in the stack trace, but in the common
> case that isn't happening because packet processing is delayed to a
> tasklet.
> 

and fwiw a patch to get this added to WARN_ON was posted by my last week to fix this;
once this goes into 2.6.25-rc this annoyance/hinderance in debugging will be fixed.
