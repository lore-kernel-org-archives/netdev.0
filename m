From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Tue, 12 Nov 2013 18:15:54 -0500 (EST)
Message-ID: <20131112.181554.988522407538617117.davem@davemloft.net>
References: <5282A5E1.9090501@cogentembedded.com>
	<20131112.161253.601617211955537751.davem@davemloft.net>
	<5282BC76.5050701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab3KLXP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 18:15:58 -0500
In-Reply-To: <5282BC76.5050701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 13 Nov 2013 02:40:38 +0300

> On 11/13/2013 12:12 AM, David Miller wrote:
> 
>>>> @@ -100,7 +100,7 @@ struct lance_init_block {
>>>>     */
>>>>    struct lance_private
>>>>    {
>>>> -        char *name;
>>>> +        const char *name;
> 
>>>     Indent with tab, not spaces, please.
> 
>> This whole file is %99 space indentation, you really can't blame
>> Geert for this.
> 
>    It's never late to fix some. And remember about checkpatch.pl which
>    was hardly content with the patch.

Good point, Geert please respin this, thanks.
