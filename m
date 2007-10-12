From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Update function names in /proc/net/tcp documentation
Date: Fri, 12 Oct 2007 16:13:32 -0700
Message-ID: <470FFF9C.7040402@hp.com>
References: <20071012225426.2f866ae6@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56197 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760845AbXJLXNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 19:13:35 -0400
In-Reply-To: <20071012225426.2f866ae6@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Delvare wrote:
> Update function name references to match the current code.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> ---
>  Documentation/networking/proc_net_tcp.txt |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-2.6.23.orig/Documentation/networking/proc_net_tcp.txt	2007-02-04 19:44:54.000000000 +0100
> +++ linux-2.6.23/Documentation/networking/proc_net_tcp.txt	2007-10-12 22:50:15.000000000 +0200
> @@ -1,8 +1,8 @@
>  This document describes the interfaces /proc/net/tcp and /proc/net/tcp6.
>  
>  These /proc interfaces provide information about currently active TCP 
> -connections, and are implemented by tcp_get_info() in net/ipv4/tcp_ipv4.c and
> -tcp6_get_info() in net/ipv6/tcp_ipv6.c, respectively.
> +connections, and are implemented by tcp4_seq_show() in net/ipv4/tcp_ipv4.c
> +and tcp6_seq_show() in net/ipv6/tcp_ipv6.c, respectively.
>  
>  It will first list all listening TCP sockets, and next list all established
>  TCP connections. A typical entry of /proc/net/tcp would look like this (split 

/proc/net/[tcp|tcp6] are deprecated now right?  Perhaps there should be 
something to that effect added to the txt.

rick jones

