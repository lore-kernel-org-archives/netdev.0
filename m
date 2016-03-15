From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next v3 1/2] RDS: TCP: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 12:21:44 -0700
Message-ID: <56E860C8.8020208@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38922 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932665AbcCOTVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 15:21:50 -0400
In-Reply-To: <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/15/2016 11:53 AM, Sowmini Varadhan wrote:
> Add per-net sysctl tunables to set the size of sndbuf and
> rcvbuf on the kernel tcp socket.
>
> The tunables are added at /proc/sys/net/rds/tcp/rds_tcp_sndbuf
> and /proc/sys/net/rds/tcp/rds_tcp_rcvbuf.
>
> Since these values must be set before accept() or connect(),
> and there may be an arbitrary number of existing rds-tcp
> sockets when the tunable is modified. To make sure that all
> connections in the netns pick up the same value for the tunable,
> we reset existing rds-tcp connections in the netns, so that
> they can reconnect with the new parameters.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2; use sysctl instead of module param. Tunabes are now per netns,
>      and can be dynamically modified without restarting all namespaces.
> v3: review comments from Santosh Shilimkar,  Eric Dumazet
>
>   net/rds/tcp.c |  143 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
>   1 files changed, 134 insertions(+), 9 deletions(-)
>
This version looks fine to me. Thanks !!

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
