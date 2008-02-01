From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] rtnetlink.c: #if 0 no longer used functions
Date: Fri, 01 Feb 2008 08:00:24 +0100
Message-ID: <47A2C388.3070404@trash.net>
References: <20080130200257.GD29368@does.not.exist>	<47A0D851.9050408@trash.net> <20080131.171751.192428440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38762 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbYBAHAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 02:00:31 -0500
In-Reply-To: <20080131.171751.192428440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 30 Jan 2008 21:04:33 +0100
> 
>> Adrian Bunk wrote:
>>> This patch #if 0's the following no longer used functions:
>>> - rtattr_parse()
>>> - rtattr_strlcpy()
>>> - __rtattr_parse_nested_compat()
>>>   
>> Please remove them instead.
> 
> Agreed.

The rtattr_parse_nested_compat macro can also go away.
