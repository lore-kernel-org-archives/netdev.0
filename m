From: Rufus & Azrael <rufus-azrael@numericable.fr>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user
 with the same regression
Date: Sat, 23 Aug 2008 22:13:25 +0200
Message-ID: <48B06F65.8070603@numericable.fr>
References: <260012.74088.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>,
	Vivek Goyal <vgoyal@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fb2.tech.numericable.fr ([82.216.111.50]:51258 "EHLO
	fb2.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908AbYHWUWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 16:22:32 -0400
Received: from smtp2.tech.numericable.fr (smtp2.nc.sdv.fr [10.0.0.36])
	by fb2.tech.numericable.fr (Postfix) with ESMTP id D541219D0B0
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 22:14:59 +0200 (CEST)
In-Reply-To: <260012.74088.qm@web82105.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Witbrodt wrote:
>    
>> Thanks Yinghai,
>>
>> Your patch applied, I attach lspci -vvxxxx.
>>
>> Regards.
>>      
>
> Hello "Rufus&  Azrael",
>
> Are you experiencing the same difficulties with kernels hanging after
> version 2.6.25?
>
> In my case, kernels before 2.6.26 worked fine, but all kernels since
> 2.6.26 hang during boot, and the problem was traced (using 'git bisect')
> to commit number 3def3d6d.
>
> Please let me know your situation.
>
>
> Thanks,
> Dave W.
>
>    
Hello David,

I have no such hanging on my recent kernels, just the dmesg :

> [    1.057255] hpet_resources: 0xfed00000 is busy
and I find the present post to try solving this regression.

Regards.


