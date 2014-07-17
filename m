From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] udp: Fix multicast performance issues.
Date: Wed, 16 Jul 2014 23:30:41 -0700 (PDT)
Message-ID: <20140716.233041.828381749836788214.davem@davemloft.net>
References: <1405481312-7790-1-git-send-email-drheld@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, willemb@google.com
To: drheld@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaGQGam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:30:42 -0400
In-Reply-To: <1405481312-7790-1-git-send-email-drheld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Held <drheld@google.com>
Date: Tue, 15 Jul 2014 23:28:30 -0400

> Fix performance issues with listening to many different multicast
> sockets on different addresses with the same port. Instead of always
> using hash1, fall back to hash2 lookup when hash1 lookup is long.
> Patch 1 is a general cleanup and simplification which also makes the
> main implementation in Patch 2 simpler.
> 
> Eric's recent change 63c6f81cdde5 avoided this being an issue in early
> demux. This makes it work for regular delivery as well.
> 
> v1->v2
>  - updated hash collision detection
> 
> v2->v3
>  - avoid flushing under lock unnecessarily at ARRAY_SIZE boundary

Series applied, thanks a lot David.
