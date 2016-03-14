From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Mon, 14 Mar 2016 13:26:13 -0700
Message-ID: <1457987173.31401.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	 <1457703594-9482-9-git-send-email-saeedm@mellanox.com>
	 <1457706771.2663.37.camel@edumazet-ThinkPad-T530>
	 <CALzJLG_XU-KMp8dMqcNOpu1OxZRnJro4LFQohK=FLX+5uJKXpQ@mail.gmail.com>
	 <1457726319.2663.50.camel@edumazet-ThinkPad-T530>
	 <CALzJLG9rB4iBnOC0f+8NopjdS407-WJ9b7KFUPO9hjbwFCyP-A@mail.gmail.com>
	 <CAEHy93JgcwKFRK+6ZVXgee77N6h+QbBNoAhE61sd0t6-0dnE1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: achiad shochat <achiad.mellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33236 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbcCNU0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 16:26:16 -0400
Received: by mail-pa0-f48.google.com with SMTP id fl4so163737496pad.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 13:26:16 -0700 (PDT)
In-Reply-To: <CAEHy93JgcwKFRK+6ZVXgee77N6h+QbBNoAhE61sd0t6-0dnE1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-14 at 21:16 +0200, achiad shochat wrote:

> Eric, am I missing something here or the new scheme was not clear to
> you previously?

I simply do not want to see drivers using 

1) SKB_TRUESIZE()

or 

2)

   skb->truesize =  some_expression


Drivers should not assume they know better than core networking stack.
