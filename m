From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 3/3] ipv4: kill RTO_ONLINK, RT_CONN_FLAGS and
 RT_CONN_FLAGS_TOS
Date: Mon, 13 Jun 2016 16:40:54 -0600
Message-ID: <37f32e2c-13e9-27af-6a14-2d379073b4aa@cumulusnetworks.com>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
 <1465850858-8559-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36257 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422745AbcFMWk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 18:40:57 -0400
Received: by mail-pa0-f48.google.com with SMTP id b5so49666315pas.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 15:40:57 -0700 (PDT)
In-Reply-To: <1465850858-8559-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/16 2:47 PM, Hannes Frederic Sowa wrote:
> Unfortunately because of bisectability I cannot split this patch. :(
>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  drivers/net/bonding/bond_main.c |  3 +--
>  drivers/net/gtp.c               |  3 ++-
>  drivers/net/ppp/pptp.c          |  2 +-
>  drivers/net/vrf.c               |  7 -------
>  include/net/ip.h                |  5 -----
>  include/net/route.h             | 38 ++++++++++++++++++++++++++++----------
>  net/dccp/ipv4.c                 |  5 +++--
>  net/ipv4/af_inet.c              |  4 ++--
>  net/ipv4/arp.c                  |  4 ++--
>  net/ipv4/datagram.c             |  5 +++--
>  net/ipv4/inet_connection_sock.c | 11 ++++++-----
>  net/ipv4/ip_output.c            |  2 +-
>  net/ipv4/ping.c                 |  6 +++---
>  net/ipv4/raw.c                  | 13 ++++++++-----
>  net/ipv4/route.c                | 18 +++++++-----------
>  net/ipv4/syncookies.c           |  4 ++--
>  net/ipv4/tcp_ipv4.c             |  2 +-
>  net/ipv4/udp.c                  |  6 +++---
>  net/l2tp/l2tp_ip.c              |  3 ++-
>  net/sctp/protocol.c             |  6 ++++--
>  20 files changed, 79 insertions(+), 68 deletions(-)

Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
