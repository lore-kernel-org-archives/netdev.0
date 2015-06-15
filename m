From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net-next 0/3] Socket destruction events via netlink
 sock_diag
Date: Mon, 15 Jun 2015 14:20:25 -0300
Message-ID: <20150615172025.GV4049@localhost.localdomain>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755451AbbFORU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 13:20:29 -0400
Content-Disposition: inline
In-Reply-To: <1434381980-20588-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2015 at 11:26:17AM -0400, Craig Gallek wrote:
> This series extends the netlink sock_diag interface to broadcast
> socket information as they are being destroyed.  The current
> interface is poll based and can not be used to retreive information
> about sockets that are destroyed between poll intervals.
> 
> Only inet sockets are broadcast in this implementation, but other
> families could easily be added as needed in the future.
> 
> If this patch set is accepted, a follow-up patch to the ss utility
> in the iproute2 suite will also be submitted.
> 
> Craig Gallek (3):
>   sock_diag: define destruction multicast groups
>   sock_diag: specify info_size per inet protocol
>   sock_diag: implement a get_info handler for inet
> 
>  include/linux/inet_diag.h      |  1 +
>  include/linux/sock_diag.h      | 42 +++++++++++++++++++++
>  include/net/sock.h             |  1 +
>  include/uapi/linux/inet_diag.h |  3 +-
>  include/uapi/linux/sock_diag.h | 10 +++++
>  net/core/sock.c                | 11 +++++-
>  net/core/sock_diag.c           | 85 ++++++++++++++++++++++++++++++++++++++++++
>  net/dccp/diag.c                |  1 +
>  net/ipv4/inet_diag.c           | 50 ++++++++++++++++++++++++-
>  net/ipv4/tcp.c                 |  4 +-
>  net/ipv4/tcp_diag.c            |  6 ++-
>  net/ipv4/udp_diag.c            |  2 +
>  12 files changed, 209 insertions(+), 7 deletions(-)
> 
> -- 
> 2.2.0.rc0.207.ga3a616c
> 

Looks good to me, thanks Craig.
Reviewed-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
