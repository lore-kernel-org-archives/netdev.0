From: Ian Molton <ian.molton@collabora.co.uk>
Subject: Re: [PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Thu, 10 Feb 2011 13:35:58 +0000
Message-ID: <4D53E9BE.4030500@collabora.co.uk>
References: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>	 <1297341067-12264-2-git-send-email-ian.molton@collabora.co.uk> <1297344292.2493.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net, isdn@linux-pingi.de,
	paulus@samba.org, arnd@arndb.de, davem@davemloft.net,
	herbert@gondor.apana.org.au, ebiederm@xmission.com,
	alban.crequy@collabora.co.uk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:35632 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab1BJNgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 08:36:01 -0500
In-Reply-To: <1297344292.2493.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/11 13:24, Eric Dumazet wrote:

Hi!

Thanks for reviewing! :)

>> * Can sk_run_filter() be called in a context where kmalloc(GFP_KERNEL) is
>>    not allowed (I think not)
>
> You cannot use GFP_KERNEL in sk_run_filter() : We run in {soft}irq mode,
> in input path.

Ok, that can be sorted.

>> * Data section allocated with second call to sock_kmalloc().
>> * Should the patch be broken into two - one to add the data uploading,
>>    one to add the JMEMCMP insn. ?
>
> May I ask why it is needed at all ?

So we can match strings in packet filters... I don't think I understand 
the question...

> Then, why only one JMEMCMP would be allowed in a filter ?

I dont think I'm restricting the filter to only have one JMEMCMP? Am I 
misunderstanding you?

-Ian
