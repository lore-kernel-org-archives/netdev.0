From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-stable 3.3..3.12] inet_diag: fix
 inet_diag_dump_icsk() timewait socket state logic
Date: Sun, 02 Feb 2014 23:30:24 -0800 (PST)
Message-ID: <20140202.233024.892737737784405273.davem@davemloft.net>
References: <1391391613-687-1-git-send-email-ncardwell@google.com>
	<1391399657.28432.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaBCHa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 02:30:27 -0500
In-Reply-To: <1391399657.28432.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 Feb 2014 19:54:17 -0800

> On Sun, 2014-02-02 at 20:40 -0500, Neal Cardwell wrote:
> ...
>> An analogous fix is in v3.13: 70315d22d3c7383f9a508d0aab21e2eb35b2303a
>> ("inet_diag: fix inet_diag_dump_icsk() to use correct state for
>> timewait sockets") but that patch is quite different because 3.13 code
>> is very different in this area due to the unification of TCP hash
>> tables in 05dbc7b ("tcp/dccp: remove twchain") in v3.13-rc1.
> ...
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/ipv4/inet_diag.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Queued up, thanks Neal.
