From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix a timewait refcnt race
Date: Thu, 03 Dec 2009 22:39:54 -0800 (PST)
Message-ID: <20091203.223954.255415131.davem@davemloft.net>
References: <4B17979D.4040301@gmail.com>
	<99d458640912031920n7e4e0f39o4c04e9c51b46efd@mail.gmail.com>
	<4B18AC31.3040800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net
To: eric.dumazet@gmail.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B18AC31.3040800@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Dec 2009 07:29:05 +0100

> kapil dakhane a écrit :
>> 
>> I applied your changes are suggested above. It appears that the patch
>> successfully resolves the race condition it addressed. I managed to
>> push the system to 1.9 gbps, previously I could not push it beyond 1.6
>> gbps. Unfortunately, there appear to be more race conditions, as the
>> fault happened again when I attempted to push it to 2.3 gbps. This
>> time I did not get any error message in /var/log/messages, although
>> they appear on the console the same way as before.
>> 
> 
> Thanks for testing Kapil
> 
> I am not sure of exact set of changes you have in your kernel.
> 
> David, could you push your net-next-2.6 tree with pending changes so that
> I can work on bind() side (interaction with timewait) and be sure Kapil
> can work on latest net-next-2.6 ?

Done.
