From: Miika Komu <miika@iki.fi>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Mon, 5 May 2008 08:55:49 +0300 (EEST)
Message-ID: <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
References: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
 <20080429.152014.00555445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twilight.cs.hut.fi ([130.233.40.5]:63223 "EHLO
	twilight.cs.hut.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbYEEFz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 01:55:57 -0400
In-Reply-To: <20080429.152014.00555445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Apr 2008, David Miller wrote:

Hi,

> From: Miika Komu <miika@iki.fi>
> Date: Wed, 30 Apr 2008 00:07:56 +0300 (EEST)
>
>> Host Identity Protocol (HIP, RFC5201, RFC4423) and Site Multihoming for
>> IPv6 (SHIM6, draft-ietf-shim6-proto-10) define new APIs in the URLs below.
>> This patch exports some IPv6 symbols to help in initial IETF
>> experimentation with external kernel modules for HIP and SHIM6 socket
>> handlers. The SHIM6 and HIP socket handlers are built on top of IPv6
>> socket handlers.
>> http://www.ietf.org/internet-drafts/draft-ietf-hip-native-api-04.txt
>> http://www.ietf.org/internet-drafts/draft-ietf-shim6-multihome-shim-api-05.txt
>>
>>
>> Signed-off-by: Miika Komu <miika@iki.fi>
>
> This is not how we do things.
>
> When the HIP implementation is submitted for inclusion, the module
> exports can be added, not before.

I am sorry but this somewhat conflicts with your earlier statement:

http://www.linux.sgi.com/archives/netdev/2005-03/msg01214.html

We took an huge effort in our project to move the HIP implementation to 
the userland. I feel puzzled on how to continue. Please give some advice?

-- 
Miika Komu                                       http://www.iki.fi/miika/
