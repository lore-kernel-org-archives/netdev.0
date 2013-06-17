From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 0/2] Two SCTP cleanup patches
Date: Mon, 17 Jun 2013 09:56:06 -0400
Message-ID: <51BF1576.4080203@gmail.com>
References: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f170.google.com ([209.85.213.170]:55328 "EHLO
	mail-ye0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab3FQN4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 09:56:10 -0400
In-Reply-To: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2013 05:40 AM, Daniel Borkmann wrote:
> Two cleanup-only patches to make the code more readable and consistent
> with the rest of the kernel code.
>
> Daniel Borkmann (2):
>    net: sctp: get rid of t_new macro for kzalloc
>    net: sctp: remove SCTP_STATIC macro
>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
>   include/net/sctp/sctp.h  | 11 -------
>   net/sctp/associola.c     |  2 +-
>   net/sctp/bind_addr.c     |  2 +-
>   net/sctp/chunk.c         |  2 +-
>   net/sctp/endpointola.c   |  3 +-
>   net/sctp/input.c         |  4 +--
>   net/sctp/ipv6.c          |  6 ++--
>   net/sctp/protocol.c      |  6 ++--
>   net/sctp/sm_make_chunk.c | 10 +++----
>   net/sctp/socket.c        | 78 ++++++++++++++++++++++--------------------------
>   net/sctp/transport.c     |  2 +-
>   net/sctp/tsnmap.c        | 10 +++----
>   net/sctp/ulpevent.c      | 10 +++----
>   13 files changed, 64 insertions(+), 82 deletions(-)
>
