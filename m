From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipconfgi: add declaration for ic_addrservaddr
Date: Thu, 09 Jun 2016 11:45:29 -0700 (PDT)
Message-ID: <20160609.114529.1278133355511511268.davem@davemloft.net>
References: <57595469.7010708@iogearbox.net>
	<ab991904-5443-1b2a-cae0-ff9697690f05@codethink.co.uk>
	<57595DEF.8010105@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@lists.codethink.co.uk,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFISpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 14:45:30 -0400
In-Reply-To: <57595DEF.8010105@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 09 Jun 2016 14:15:43 +0200

> On 06/09/2016 02:11 PM, Ben Dooks wrote:
>> On 09/06/16 12:35, Daniel Borkmann wrote:
>>> On 06/09/2016 01:07 PM, Ben Dooks wrote:
>>>> The symbol ic_addrservaddr is not static, but has no declaration
>>>> to match. Since the similar variables are all exported, add this
>>>> one to the header file as well.
>>>>
>>>> This fixes the following warning:
>>>>
>>>> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not
>>>> declared. Should it be static?
>>>>
>>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>>
>>> Well, how about making it actually static if it's only used
>>> from ipconfig.c ?
>>
>> The only reason is that I thought someone might want to
>> use it in the future. I have no particular insight though.
> 
> Usual policy is that if such thing is required, then it can be
> exported along with the code that is making use of it from elsewhere.

Right.
