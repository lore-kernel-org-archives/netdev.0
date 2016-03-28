From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 09:15:00 -0700
Message-ID: <56F95884.8010901@hpe.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
 <1458944964-12890-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:59976 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbcC1QPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 12:15:07 -0400
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com [15.201.208.56])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 2D8C463148
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 16:15:06 +0000 (UTC)
In-Reply-To: <1458944964-12890-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2016 03:29 PM, Eric Dumazet wrote:
> UDP sockets are not short lived in the high usage case, so the added
> cost of call_rcu() should not be a concern.

Even a busy DNS resolver?

rick jones
