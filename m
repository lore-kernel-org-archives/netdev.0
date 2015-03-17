From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] inet: Clean up inet_csk_wait_for_connect() vs.
 might_sleep()
Date: Tue, 17 Mar 2015 15:04:27 -0400 (EDT)
Message-ID: <20150317.150427.1040329549515743280.davem@redhat.com>
References: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbbCQTEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 15:04:53 -0400
In-Reply-To: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Mar 2015 12:19:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I got the following trace with current net-next kernel :
 ...
> In commit 26cabd31259ba43f68026ce3f62b78094124333f
> Peter added a sched_annotate_sleep() in sk_wait_event()
> 
> Is the following patch needed as well ?
> 
> Alternative would be to use sk_wait_event() from inet_csk_wait_for_connect()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
