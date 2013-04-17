From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] Minor SCTP cleanups all over the place
Date: Wed, 17 Apr 2013 14:13:21 -0400 (EDT)
Message-ID: <20130417.141321.1161500597576212704.davem@davemloft.net>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964924Ab3DQSNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:13:23 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 16 Apr 2013 23:07:09 +0200

> That's a batch of cleanups for the SCTP protocol. Probably all
> deadly boring and trivial patches, but it always bugs me. :-) I
> guess this is still from the very SCTP beginning in Linux. Well,
> at least we can now remove 41 lines of code in total. lksctp-tools
> test suite run through without problems.
> 
> Daniel Borkmann (9):
>   net: sctp: sctp_ssnmap: remove 'malloced' element from struct
>   net: sctp: sctp_inq: remove dead code
>   net: sctp: sctp_outq: remove 'malloced' from its struct
>   net: sctp: sctp_outq: consolidate chars into bitfield
>   net: sctp: outqueue: simplify sctp_outq_uncork function
>   net: sctp: sctp_transport: remove unused variable
>   net: sctp: sctp_bind_addr: remove dead code
>   net: sctp: sctp_ulpq: remove 'malloced' struct member
>   net: sctp: sctp_ulpq: do not use char as a struct member

All applied except for #4 and #9, thanks.
