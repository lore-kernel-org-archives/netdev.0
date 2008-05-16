From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Fri, 16 May 2008 11:19:51 -0700
Message-ID: <482DD047.7060907@linux.intel.com>
References: <482DB93B.2080100@linux.intel.com> <20080516180426.GA3284@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:33329 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754516AbYEPSTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 14:19:55 -0400
In-Reply-To: <20080516180426.GA3284@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> On Fri, May 16, 2008 at 09:41:31AM -0700, Arjan van de Ven wrote:
>> ...
>> Bug of the week
>> ---------------
>> Not in the top 10 (but barely not so), but upcoming fast is a bug that has a very
>> distinct pattern.
>> The backtraces are at http://www.kerneloops.org/searchweek.php?search=fput
>>
>> The pattern is that the kernel gets an invalid pointer passed to fput(),
>> coming down from a select() system call done by the "wpa_supplicant" program.
>> The fact that it is ONLY wpa_supplicant implicates the wireless/network stack.
>> Another observation is that this only happens with 64 bit kernels, even though
>> a large portion of the users uses 32 bit kernels. This implies that this is a 64-bit
>> type of bug. It appears that the top 32 bit of the pointers is getting corrupted
>> (the bottom part at least looks valid).
>> ...
> 
> Unless I misunderstand your webinterface another pattern is a "fc9" in 
> the version string.

that's because fc9 is the only OS that currently ships the client by default,
which means that it's a statistical thing where 90%+ of the reports come from
Fedora kernels, just because that's where the data is mined.

> 
> My first guess would be that it might be a problem in some code that is 
> only in Fedora kernels?

that may or may not be true, but we can't conclude that right now.
