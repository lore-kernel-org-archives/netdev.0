From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 06:44:15 -0800
Message-ID: <1393512255.26794.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
	 <1393504026-13384-4-git-send-email-amirv@mellanox.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CCB7E@AcuExch.aculab.com>
	 <20140227140203.GA13112@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:42822 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbaB0OoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 09:44:18 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp16so2594754pbb.31
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 06:44:17 -0800 (PST)
In-Reply-To: <20140227140203.GA13112@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 16:02 +0200, Amir Vadai wrote:
>  
> Yes, skb will not be classified as inline-able if nr_frags != 1.
> See is_inline()

How often this inline stuff ever happens ?

It looks like the length of the frame needs to be shorter than 44 bytes,
right ?

Minimal length for TCP is 54 bytes.

I wonder why you tried to inline stuff that is probably never
seen in real workload.
