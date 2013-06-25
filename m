From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] Further SCTP changes
Date: Tue, 25 Jun 2013 16:31:42 -0700 (PDT)
Message-ID: <20130625.163142.640541864547549849.davem@davemloft.net>
References: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3FYXbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:31:43 -0400
In-Reply-To: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 25 Jun 2013 18:17:24 +0200

> Mostly it's all about getting rid of unnecessary code, and/or making
> it more clean and readable. Code has been tested with lksctp-tools
> functional test suite and also my small sctp stress test helper that
> was used to discover the recent null-ptr derefs.
> 
> v2->v3:
>   - Just changed "net: sctp: decouple cleaning some socket data from endpoint"
>     patch description slightly and made assignment explicit as Vlad requested
>   - Rest is unchanged
> v1->v2:
>   - Left sctp_put_port() still in sctp_endpoint_destroy() for now
>   - Added minor "net: sctp: simplify sctp_get_port" patch

Series applied, thanks everyone.
