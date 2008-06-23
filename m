From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] hfsc: add link layer overhead adaption
Date: Mon, 23 Jun 2008 13:27:26 +0200
Message-ID: <485F889E.1050901@trash.net>
References: <20080623102514.15821.13979.stgit@fate.lan>	<485F81B2.7000107@trash.net> <20080623142417.9gxuu3y9r4084s4c@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45958 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbYFWL1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:27:30 -0400
In-Reply-To: <20080623142417.9gxuu3y9r4084s4c@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Quoting Patrick McHardy <kaber@trash.net>:
>>
>> This looks like an abuse of rate tables, which usually convert
>> packet sizes to transmission times. You undo that above using
>> expensive calculations.
>>
>> I think this should be done by performing the length calculation
>> in the kernel directly.
> 
> Yes, it's abuse, and actually table is created using false rate (rate = 
> PSCHED_TICKS_PER_SEC) so div_u64 is avoided. Div_u64 is there just in 
> case something goes wrong in userspace. Using rate table allows 
> changes/updates to link layer emulation with only userspace updates 
> avoiding, but maybe abuse of rate table isn't right way to do this after 
> all.
> 
> So would it be better if I add 'length table' to kernel&userspace and 
> use it instead?

Yes, I even posted an unfinished patch for this one or two years
ago, in response to the overhead calculation patches for HTB etc.

I can't find it right now, but haven't tried too hard. It was
called qdisc STABs (for size tables), you should be able to find
it in the archives.
