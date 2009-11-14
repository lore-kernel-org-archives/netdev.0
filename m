From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] igmp: Use next_net_device_rcu()
Date: Fri, 13 Nov 2009 20:39:31 -0800 (PST)
Message-ID: <20091113.203931.90131286.davem@davemloft.net>
References: <4AFB85A4.1050408@gmail.com>
	<20091111211435.570b259a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932262AbZKNEjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:39:15 -0500
In-Reply-To: <20091111211435.570b259a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 11 Nov 2009 21:14:35 -0800

> On Thu, 12 Nov 2009 04:48:52 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> We need to use next_det_device_rcu() in RCU protected section.
>> 
>> We also can avoid in_dev_get()/in_dev_put() overhead (code size mainly)
>> in rcu_read_lock() sections.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
