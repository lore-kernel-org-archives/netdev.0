From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] ipvs: Make the synchronization interval controllable
Date: Wed, 6 Feb 2008 14:09:55 -0800 (PST)
Message-ID: <alpine.DEB.1.00.0802061409130.7879@chino.kir.corp.google.com>
References: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:34381 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834AbYBFWKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 17:10:06 -0500
In-Reply-To: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Feb 2008, Sven Wegener wrote:

> diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
> index 948378d..9b57ad3 100644
> --- a/net/ipv4/ipvs/ip_vs_sync.c
> +++ b/net/ipv4/ipvs/ip_vs_sync.c
> @@ -143,6 +143,8 @@ char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
>  /* multicast addr */
>  static struct sockaddr_in mcast_addr;
>  
> +/* milliseconds between synchronization runs */
> +int sysctl_ip_vs_sync_interval = 1000;
>  
>  static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
>  {

How useful is a negative ip_vs_sync_interval?
