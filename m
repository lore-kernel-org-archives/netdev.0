From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] igmp: Use next_net_device_rcu()
Date: Wed, 11 Nov 2009 21:14:35 -0800
Message-ID: <20091111211435.570b259a@nehalam>
References: <4AFB85A4.1050408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59918 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902AbZKLFPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 00:15:00 -0500
In-Reply-To: <4AFB85A4.1050408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 04:48:52 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> We need to use next_det_device_rcu() in RCU protected section.
> 
> We also can avoid in_dev_get()/in_dev_put() overhead (code size mainly)
> in rcu_read_lock() sections.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
