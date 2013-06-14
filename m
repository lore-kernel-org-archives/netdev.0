From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Some SCTP cleanups/improvements
Date: Thu, 13 Jun 2013 17:45:30 -0700 (PDT)
Message-ID: <20130613.174530.2244357764542712221.davem@davemloft.net>
References: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757625Ab3FNApb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:45:31 -0400
In-Reply-To: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 13 Jun 2013 18:04:19 +0200

> v1 -> v2:
>   - Apply Neil's feedback, I'll send out the first patch at a later
>     point in time though, have not included it in this set
>   - Add two other patches that appear to be useful from the last
>     couple of days debugging SCTP code
> 
> Daniel Borkmann (4):
>   net: sctp: throw BUG if primary_path in sctp_seq_dump_local_addrs is NULL
>   net: sctp: sctp_sf_do_prm_asoc: do SCTP_CMD_INIT_CHOOSE_TRANSPORT first
>   net: sctp: minor: remove variable in sctp_init_sock
>   net: sctp: sctp_association_init: put refs in reverse order on error

Looks good to me, SCTP folks please review.
