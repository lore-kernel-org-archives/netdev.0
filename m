From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] tcp: Initial repair mode
Date: Tue, 06 Mar 2012 15:16:58 -0500 (EST)
Message-ID: <20120306.151658.221409592839431715.davem@davemloft.net>
References: <4F55DEDE.1090602@parallels.com>
	<4F55DF12.6030001@parallels.com>
	<4F560D13.4000404@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org, tj@kernel.org,
	eric.dumazet@gmail.com
To: glommer@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030950Ab2CFURF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 15:17:05 -0500
In-Reply-To: <4F560D13.4000404@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glauber Costa <glommer@parallels.com>
Date: Tue, 6 Mar 2012 17:11:47 +0400

> On 03/06/2012 01:55 PM, Pavel Emelyanov wrote:
>> This includes (according the the previous description):
>>
>> * TCP_REPAIR sockoption
>>
>> This one just puts the socket in/out of the repair mode.
>> Allowed for CAP_SYS_ADMIN and for closed/establised sockets only.
>> When repair mode is turned off and the socket happens to be in
>> the established state the window probe is sent to the peer to
>> 'unlock' the connection.
> 
> Why not CAP_NET_ADMIN, or something similar?

Agreed, we made this kind of mistake with the transparent proxy stuff,
let's not do that again.
