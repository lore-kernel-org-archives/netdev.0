From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ip_gre: increase inner ip header ID during
 segmentation
Date: Fri, 22 Mar 2013 15:57:50 +0800
Message-ID: <1363939070.27685.16.camel@cr0>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab3CVH6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 03:58:30 -0400
In-Reply-To: <1363938600-26129-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 15:50 +0800, Cong Wang wrote:
> +		iph = (struct iphdr *)skb->data;
> +		iph->id = id++;

Oops, seems I missed its endian...
