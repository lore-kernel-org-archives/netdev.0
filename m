From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Netfilter SYNPROXY mss and wscale bugfix
Date: Thu, 14 Nov 2013 15:41:35 +0100
Message-ID: <20131114154135.5c0829b0@redhat.com>
References: <1384439731-16296-1-git-send-email-mph@one.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, brouer@redhat.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Topholm <mph@one.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab3KNOls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 09:41:48 -0500
In-Reply-To: <1384439731-16296-1-git-send-email-mph@one.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Nov 2013 15:35:29 +0100
Martin Topholm <mph@one.com> wrote:

> The following series fixes two bugs we have discovered in the netfilter
> module SYNPROXY.
> 
> The first is related to the mss option not getting transferred to the
> backend servers.
> 
> And the second it related to passing of the windows scaling option.
> 
> Martin Topholm (2):
>   netfilter: synproxy: send mss option to backend
>   netfilter: synproxy: correct wscale option passing
> 
>  net/ipv4/netfilter/ipt_SYNPROXY.c  | 1 +
>  net/ipv6/netfilter/ip6t_SYNPROXY.c | 1 +
>  net/netfilter/nf_synproxy_core.c   | 7 ++++---
>  3 files changed, 6 insertions(+), 3 deletions(-)

ACK series

I have already reviewed the patches offlist with Martin and helped him
on howto submit patches etc.. Nice work Martin :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
