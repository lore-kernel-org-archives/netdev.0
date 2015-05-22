From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: Flush all skbs related to an
 unregistered device
Date: Thu, 21 May 2015 23:21:44 -0400 (EDT)
Message-ID: <20150521.232144.2264860678021621099.davem@davemloft.net>
References: <1432077893-4431-2-git-send-email-baptiste@arista.com>
	<20150521.170219.1689248066169954260.davem@davemloft.net>
	<CA+HUmGgqf9CDUx374hSrKVXoYAnc+dNWuh04VTT6m0LcaSuGiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baptiste@arista.com, netdev@vger.kernel.org, mowat@arista.com,
	adrien+dev@schischi.me
To: fruggeri@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbbEVDVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:21:46 -0400
In-Reply-To: <CA+HUmGgqf9CDUx374hSrKVXoYAnc+dNWuh04VTT6m0LcaSuGiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@arista.com>
Date: Thu, 21 May 2015 17:28:47 -0700

> One can change flush_backlog to also handle a list of net_devices
> instead.

Then make it do so.

Because that is the driving design of all of the bulk deregister/etc.
facilities, they operate on a list of objects and the top-level
control is responsible for the lifetime of the list.
