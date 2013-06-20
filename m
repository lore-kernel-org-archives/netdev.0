From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Further SCTP changes
Date: Wed, 19 Jun 2013 18:39:03 -0700 (PDT)
Message-ID: <20130619.183903.2165829460238667637.davem@davemloft.net>
References: <1371545720-22950-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935237Ab3FTBjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:39:04 -0400
In-Reply-To: <1371545720-22950-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 18 Jun 2013 10:55:15 +0200

> Mostly it's all about getting rid of unnecessary code, and/or making
> it more clean and readable.
> 
> Code has been tested with lksctp-tools functional test suite and
> also my small sctp stress test helper that was used to discover
> the recent null-ptr derefs. This test was also sucessfully run against
> auth_enabled=0 and auth_enabled=1, where I also previously applied
> the following two patches:
> 
>   - http://marc.info/?l=linux-crypto-vger&m=137121898331017&w=2
>     -> not yet applied, still pending review for crypto tree
>   - 1abd165 (net: sctp: fix NULL pointer dereference in socket destruction)
>     -> cherry picked from net tree
> 
> Daniel Borkmann (5):
>   net: sctp: remove TEST_FRAME ifdef
>   ktime: add ms_to_ktime() and ktime_add_ms() helpers
>   net: sctp: migrate cookie life from timeval to ktime
>   net: sctp: decouple cleaning socket data from endpoint
>   net: sctp: minor: sctp_seq_dump_local_addrs add missing newline

The discussion of this patch series has taken a tangent towards a
talk about how to do TX based socket accounting differently.

While that's interesting, it'd be good to get ACKs for Daniel's
patches meanwhile, I think they are fine personally.
