From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [patch 37/37] LTTng instrumentation net
Date: Thu, 24 Apr 2008 19:52:20 +0400
Message-ID: <4810ACB4.501@openvz.org>
References: <20080424150324.802695381@polymtl.ca> <20080424151408.991424268@polymtl.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35024 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758116AbYDXPzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:55:38 -0400
In-Reply-To: <20080424151408.991424268@polymtl.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Desnoyers wrote:
> Network core events.
> 
> Added markers :
> 
> net_del_ifa_ipv4
> net_dev_receive
> net_dev_xmit
> net_insert_ifa_ipv4
> net_socket_call
> net_socket_create
> net_socket_recvmsg
> net_socket_sendmsg

Network "core" events are not limited with the above calls.

Besides, real "core" events already sent notifications about themselves.
Why do we need additional hooks?

> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> CC: netdev@vger.kernel.org
> ---
>  net/core/dev.c     |    6 ++++++
>  net/ipv4/devinet.c |    6 ++++++
>  net/socket.c       |   19 +++++++++++++++++++
>  3 files changed, 31 insertions(+)

