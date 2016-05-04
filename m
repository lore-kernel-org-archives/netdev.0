From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH] tcp: ensure non-empty connection request queue
Date: Wed, 4 May 2016 10:24:24 -0700
Message-ID: <572A3048.60802@hpe.com>
References: <1462312458-2077-1-git-send-email-peter@lekensteyn.nl>
 <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Kui Zhang <kuizhang@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Wu <peter@lekensteyn.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:33045 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbcEDRY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:24:28 -0400
In-Reply-To: <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2016 05:25 PM, Eric Dumazet wrote:
> On Tue, 2016-05-03 at 23:54 +0200, Peter Wu wrote:
>> When applications use listen() with a backlog of 0, the kernel would
>> set the maximum connection request queue to zero. This causes false
>> reports of SYN flooding (if tcp_syncookies is enabled) or packet drops
>> otherwise.
>>

> Well, I believe I already gave my opinion on this.
>
> listen backlog is not a hint. This is a limit.
>
> It is the limit of outstanding children in accept queue.
>
> If backlog is 0, no child can be put in the accept queue.
>
> It is therefore Working As Intented.

Dropping the connection attempt makes sense, but is entering/claiming 
synflood really indicated in the case of a zero-length accept queue?

rick
