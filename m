From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] net:dccp: do not report ICMP redirects to user space
Date: Wed, 18 Sep 2013 12:34:23 -0400 (EDT)
Message-ID: <20130918.123423.1239007962081108719.davem@davemloft.net>
References: <5239968F.1070402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510Ab3IRQeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:34:31 -0400
In-Reply-To: <5239968F.1070402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 18 Sep 2013 20:03:27 +0800

> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> DCCP shouldn't be setting sk_err on redirects as it
> isn't an error condition. it should be doing exactly
> what tcp is doing and leaving the error handler without
> touching the socket.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied.
