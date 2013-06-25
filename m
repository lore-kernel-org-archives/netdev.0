From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3 0/6] Further SCTP changes
Date: Tue, 25 Jun 2013 13:54:56 -0400
Message-ID: <51C9D970.2040102@gmail.com>
References: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:52590 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab3FYRzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 13:55:01 -0400
In-Reply-To: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 12:17 PM, Daniel Borkmann wrote:
> Mostly it's all about getting rid of unnecessary code, and/or making
> it more clean and readable. Code has been tested with lksctp-tools
> functional test suite and also my small sctp stress test helper that
> was used to discover the recent null-ptr derefs.
>
> v2->v3:
>    - Just changed "net: sctp: decouple cleaning some socket data from endpoint"
>      patch description slightly and made assignment explicit as Vlad requested
>    - Rest is unchanged
> v1->v2:
>    - Left sctp_put_port() still in sctp_endpoint_destroy() for now
>    - Added minor "net: sctp: simplify sctp_get_port" patch
>
> Daniel Borkmann (6):
>    net: sctp: remove TEST_FRAME ifdef
>    ktime: add ms_to_ktime() and ktime_add_ms() helpers
>    net: sctp: migrate cookie life from timeval to ktime
>    net: sctp: minor: sctp_seq_dump_local_addrs add missing newline
>    net: sctp: decouple cleaning some socket data from endpoint
>    net: sctp: simplify sctp_get_port

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

>
>   include/linux/ktime.h      | 13 +++++++++++++
>   include/net/sctp/sctp.h    | 25 -------------------------
>   include/net/sctp/structs.h |  6 +++---
>   net/sctp/associola.c       |  8 +-------
>   net/sctp/endpointola.c     | 19 ++++++++++---------
>   net/sctp/proc.c            |  2 +-
>   net/sctp/sm_make_chunk.c   | 19 ++++++++-----------
>   net/sctp/socket.c          | 35 +++++++++++++++++++----------------
>   8 files changed, 55 insertions(+), 72 deletions(-)
>
