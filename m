From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Sat, 05 Jan 2008 19:31:29 -0800
Message-ID: <47804B91.1050709@linux.intel.com>
References: <477FF149.4070609@linux.intel.com> <p733atbr5q4.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:39282 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751502AbYAFDer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 22:34:47 -0500
In-Reply-To: <p733atbr5q4.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Arjan van de Ven <arjan@linux.intel.com> writes:
>> Rank 4: remove_proc_entry
>> 	Was also ranked 4th last week
>> 	Only in tainted oopses
>> 	Reported 3 times (12 total reports)
>> 	More info: http://www.kerneloops.org/search.php?search=remove_proc_entry
> 
> Likely a broken module_exit() function that corrupts the list. To track
> these down it might be useful to keep a list of recently unloaded modules
> and dump these too in the oops module list with a special flag.
> 
I suspect that simply printing the currently unloading module will catch 90%+ already;
I'll look into adding this, it's a very good idea.
