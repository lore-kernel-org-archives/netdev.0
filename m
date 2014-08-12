From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] sunvnet: Fixes to avoid soft lockup
Date: Tue, 12 Aug 2014 15:09:43 -0700 (PDT)
Message-ID: <20140812.150943.1385530269428339161.davem@davemloft.net>
References: <20140812142617.GG2404@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbaHLWJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:09:44 -0400
In-Reply-To: <20140812142617.GG2404@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 12 Aug 2014 10:26:17 -0400

> 
> The following patchset contains fixes for various sources of
> soft lockup in the sunvnet driver. 
> 
> Sowmini Varadhan (3):
>   sunvnet: Do not ask for an ACK for every dring transmit
>   sunvnet: Do not spin in an infinite loop when vio_ldc_send() returns EAGAIN
>   sunvnet: Schedule maybe_tx_wakeup as a tasklet from ldc_rx path

I've applied the first two patches, but I have problems with the third
one and I'd like you to rework it.  I'll reply to that patch describing
the problems.

Thanks.
