From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] Update htb rate when stats are polled.
Date: Wed, 30 May 2007 09:33:44 +0200
Message-ID: <465D28D8.7080604@trash.net>
References: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com>	 <4657E8AC.4080505@trash.net> <46582E4F.5090306@trash.net> <166fe7950705291139j7a9be295n8e3ec79ff6215555@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63443 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbXE3HeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 03:34:19 -0400
In-Reply-To: <166fe7950705291139j7a9be295n8e3ec79ff6215555@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranjit Manomohan wrote:
> On 5/26/07, Patrick McHardy <kaber@trash.net> wrote:
> 
>> You can use this patch as a base. It needs a bit more work
>> (for example the CONFIG_NET_SCHED_ESTIMATOR ifdefs are
>> unnecessary, but I've added them to remind me to clean this
>> up in all schedulers), but it works well enough for testing.
>>
>> Actually .. do you still need your changes with this patch?
>> You can now replace the default estimator by one with a
>> shorter interval.
>>
>>
> 
> I applied the patch and tried this out and it works fine with short
> intervals. My changes are no longer necessary. Thanks!


OK thanks. I'll queue it for 2.6.23.
