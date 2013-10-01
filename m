From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4 igmp: use in_dev_put in timer handlers
 instead of __in_dev_put
Date: Mon, 30 Sep 2013 22:30:17 -0700 (PDT)
Message-ID: <20130930.223017.417729492086913726.davem@davemloft.net>
References: <1380487182-1644-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: noureddine@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3JAFXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:23:12 -0400
In-Reply-To: <1380487182-1644-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@aristanetworks.com>
Date: Sun, 29 Sep 2013 13:39:42 -0700

> It is possible for the timer handlers to run after the call to
> ip_mc_down so use in_dev_put instead of __in_dev_put in the handler
> function in order to do proper cleanup when the refcnt reaches 0.
> Otherwise, the refcnt can reach zero without the in_device being
> destroyed and we end up leaking a reference to the net_device and
> see messages like the following,
> 
> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
> 
> Tested on linux-3.4.43.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

Applied and queued up for -stable.
