From: Christoph Paasch <cpaasch@apple.com>
Subject: Re: [PATCH net-next] tcp: socket option to set TCP fast open key
Date: Wed, 18 Oct 2017 16:39:50 -0700
Message-ID: <20171018233950.GZ73751@Chimay.local>
References: <20171018182251.5486-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
        ncardwell@google.com, maheshb@google.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out7.apple.com ([17.151.62.29]:57251 "EHLO
        mail-in7.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751048AbdJRXjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 19:39:51 -0400
Content-disposition: inline
In-reply-to: <20171018182251.5486-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/10/17 - 11:22:51, Yuchung Cheng wrote:
> New socket option TCP_FASTOPEN_KEY to allow different keys per
> listener.  The listener by default uses the global key until the
> socket option is set.  The key is a 16 bytes long binary data. This
> option has no effect on regular non-listener TCP sockets.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/request_sock.h |  2 ++
>  include/net/tcp.h          |  5 +++--
>  include/uapi/linux/tcp.h   |  1 +
>  net/ipv4/sysctl_net_ipv4.c |  3 ++-
>  net/ipv4/tcp.c             | 33 +++++++++++++++++++++++++++
>  net/ipv4/tcp_fastopen.c    | 56 +++++++++++++++++++++++++++++++++-------------
>  net/ipv4/tcp_ipv4.c        |  1 +
>  7 files changed, 82 insertions(+), 19 deletions(-)

Reviewed-by: Christoph Paasch <cpaasch@apple.com>


Christoph
