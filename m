From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: tc regression?
Date: Wed, 25 Jun 2008 17:54:50 +0400
Message-ID: <48624E2A.4040300@bigtelecom.ru>
References: <485FA55A.4070107@bigtelecom.ru> <485FAAF1.6060304@trash.net> <485FAC36.4040706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:51428 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125AbYFYNy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 09:54:58 -0400
In-Reply-To: <485FAC36.4040706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry for long answer.... I will try it tomorrow!...
> Patrick McHardy wrote:
>> Badalian Vyacheslav wrote:
>>> Hello all.
>>>
>>> Ditrib: Gentoo (i hope its not gentoo bug...)
>>>
>>> I try update package to "sys-apps/iproute2-2.6.25.20080417" and see 
>>> that filter can't del filter...
>>>
>>> # tc filter show dev eth1 | grep 4:29:d1
>>> filter parent 1: protocol ip pref 5 u32 fh 4:29:d1 order 209 key ht 
>>> 4 bkt 29 flowid 1:b7aa
>>>
>>> # tc filter del dev eth1 parent 1: pref 5 handle 4:29:d1 u32
>>> RTNETLINK answers: Invalid argument
>>> We have an error talking to the kernel
>>>
>>> after rollback to package"sys-apps/iproute2-2.6.24.20080108" all 
>>> deleted normal...
>>
>> The current iproute version uses "protocol all" by default
>> if its not specified. This is actually only useful for creating
>> new filters, on deletion an unset protocol is treated as wildcard.
>>
>> Does this patch fix it?
>
> Oops, buggy patch. This one should work.
>

