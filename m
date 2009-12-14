From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 10:19:53 -0800 (PST)
Message-ID: <20091214.101953.24324389.davem@davemloft.net>
References: <4B25D38F.1090702@gmail.com>
	<20091213.234530.82029083.davem@davemloft.net>
	<4B267708.3010202@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lists@nerdbynature.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.dykstra1@gmail.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932370AbZLNST4@vger.kernel.org>
In-Reply-To: <4B267708.3010202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Dec 2009 18:34:00 +0100

> And commit 96e0bf4b5193d0d97d139f99e2dd128763d55521
> (tcp: Discard segments that ack data not yet sent)
> 
> Did change this area a bit :

Good catch.

I can reproduce this quite readily so I'll try reverting that
commit.
