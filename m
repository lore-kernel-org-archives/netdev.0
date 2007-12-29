From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Top 9 kernel oopses/warnings for the week of December 29th,
 2007
Date: Sat, 29 Dec 2007 11:18:18 -0800 (PST)
Message-ID: <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org>
References: <477630CF.5070609@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756837AbXL2TSi@vger.kernel.org>
In-Reply-To: <477630CF.5070609@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 29 Dec 2007, Arjan van de Ven wrote:
>
> It has been a quiet week due to the holidays, only 55 oops traces
> have been collected.

This would be more useful if it was more readable. As it is, you seem to 
have some formatting errors in your automation, where the things are 
incorrectly grouped:

> Rank 1: sysctl_head_finish
> 	sysctl table check failed
> 	Reported 7 times
> 	Only reported for the proprietary madwifi driver
> 	More info: http://www.kerneloops.org/search.php?search=sysctl_head_finish
> 	Rank 2: __ieee80211_rx
> 	Warning at net/mac80211/rx.c:1672

ie notice how that "Rank 2" got reported as if it was part of the "Rank 1" 
issue. 

		Linus
