From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] udp: Use hash2 for long hash1 chains in
 __udp*_lib_mcast_deliver.
Date: Wed, 16 Jul 2014 09:13:07 +0200
Message-ID: <1405494787.10255.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405481312-7790-1-git-send-email-drheld@google.com>
	 <1405481312-7790-3-git-send-email-drheld@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com
To: David Held <drheld@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:64420 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaGPHNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 03:13:13 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so5572919wib.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 00:13:12 -0700 (PDT)
In-Reply-To: <1405481312-7790-3-git-send-email-drheld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 23:28 -0400, David Held wrote:
> Many multicast sources can have the same port which can result in a very
> large list when hashing by port only. Hash by address and port instead
> if this is the case. This makes multicast more similar to unicast.
> 
> On a 24-core machine receiving from 500 multicast sockets on the same
> port, before this patch 80% of system CPU was used up by spin locking
> and only ~25% of packets were successfully delivered.
> 
> With this patch, all packets are delivered and kernel overhead is ~8%
> system CPU on spinlocks.
> 
> Signed-off-by: David Held <drheld@google.com>
> ---

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks David.
