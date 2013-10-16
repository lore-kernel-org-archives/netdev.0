From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4 net 0/3] sctp: Use software checksum under certain
Date: Wed, 16 Oct 2013 10:02:32 +0200
Message-ID: <525E4818.2080101@redhat.com>
References: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	fan.du@windriver.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58443 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755174Ab3JPICi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:02:38 -0400
In-Reply-To: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 04:01 AM, Vlad Yasevich wrote:
> There are some cards that support SCTP checksum offloading.  When using
> these cards with IPSec or forcing IP fragmentation of SCTP traffic,
> the checksum is computed incorrectly due to the fact that xfrm and IP/IPv6
> fragmentation code do not know that this is SCTP traffic and do not
> know that checksum has to be computed differently.
>
> To fix this, we let SCTP detect these conditions and perform software
> checksum calculation.
>
> Fan Du (1):
>    sctp: Use software crc32 checksum when xfrm transform will happen.
>
> Vlad Yasevich (2):
>    net: dst: provide accessor function to dst->xfrm
>    sctp: Perform software checksum if packet has to be fragmented.
>
>   include/net/dst.h | 12 ++++++++++++
>   net/sctp/output.c |  3 ++-
>   2 files changed, 14 insertions(+), 1 deletion(-)
>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
