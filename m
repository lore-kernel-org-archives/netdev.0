From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH] tcp: ensure non-empty connection request queue
Date: Wed, 4 May 2016 11:05:26 -0700
Message-ID: <572A39E6.1020001@hpe.com>
References: <1462312458-2077-1-git-send-email-peter@lekensteyn.nl>
 <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
 <572A3048.60802@hpe.com>
 <1462383266.5535.350.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Wu <peter@lekensteyn.nl>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Kui Zhang <kuizhang@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:55059 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985AbcEDSFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:05:30 -0400
In-Reply-To: <1462383266.5535.350.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2016 10:34 AM, Eric Dumazet wrote:
> On Wed, 2016-05-04 at 10:24 -0700, Rick Jones wrote:
>
>> Dropping the connection attempt makes sense, but is entering/claiming
>> synflood really indicated in the case of a zero-length accept queue?
>
> This is a one time message.
>
> This is how people can learn about their user space bugs, or too small
> backlog ;)
>
> Being totally silent would be not so nice.
>

Assuming Peter's assertion about just drops when syncookies are not 
enabled is accurate, should there be some one-time message in that case too?

rick
