From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 04:08:40 +0900 (JST)
Message-ID: <20060622.040840.09265293.yoshfuji@linux-ipv6.org>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:11784 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932673AbWFUTHq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 15:07:46 -0400
To: swise@opengridcomputing.com
In-Reply-To: <20060621184519.10425.69175.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060621184519.10425.69175.stgit@stevo-desktop> (at Wed, 21 Jun 2006 13:45:19 -0500), Steve Wise <swise@opengridcomputing.com> says:

> This patch implements a mechanism that allows interested clients to
> register for notification of certain network events. The intended use
> is to allow RDMA devices (linux/drivers/infiniband) to be notified of
> neighbour updates, ICMP redirects, path MTU changes, and route changes.

Why not netlink?
Neighbor / routing updates should be transmitted via netlink, at least.

--yoshfuji
