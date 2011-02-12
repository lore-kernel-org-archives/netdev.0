From: Ian Molton <ian.molton@collabora.co.uk>
Subject: Re: [RFD][PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Sat, 12 Feb 2011 12:47:40 +0000
Message-ID: <4D56816C.9070006@collabora.co.uk>
References: <1297340087-10963-1-git-send-email-ian.molton@collabora.co.uk> <20110212021441.GA3035@sammy.paulus.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net, isdn@linux-pingi.de,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:60774 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465Ab1BLMrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 07:47:42 -0500
In-Reply-To: <20110212021441.GA3035@sammy.paulus.ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/11 02:14, Paul Mackerras wrote:
> On Thu, Feb 10, 2011 at 12:14:46PM +0000, Ian Molton wrote:
>
>> This patch implements an extension for BPF to allow filter programs to use a
>> data section, along with a MEMCMP instruction.
>>
>> There are a few issues noted in the patch itself, which can easily be
>> addressed, and I would like to check wether sk_run_filter is ever expected to
>> be called from a context that cannot sleep (I dont think it is).
>
> The ppp driver (ppp_generic.c) calls sk_run_filter inside a region
> protected by spin_lock_bh, so we can't sleep there.  Having sk_run_filter
> potentially sleep would make it useless for ppp.

Thanks for the review.

I'll fix it not to sleep :)

Do I take it from the lack of people comlpaining that the concept of 
adding this type of instruction itself is not a problem ?

Thanks!

-Ian
