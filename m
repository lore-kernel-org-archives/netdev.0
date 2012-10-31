From: David Miller <davem@davemloft.net>
Subject: Re: tcp_metrics: dumb bug
Date: Wed, 31 Oct 2012 12:46:39 -0400 (EDT)
Message-ID: <20121031.124639.2059872320833955948.davem@davemloft.net>
References: <20121030085920.3c64ebd1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758120Ab2JaQqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:46:42 -0400
In-Reply-To: <20121030085920.3c64ebd1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 30 Oct 2012 08:59:20 -0700

> https://bugzilla.kernel.org/show_bug.cgi?id=49171
> 
> Description From David Binderman 2012-10-21 10:31:05 (-) [reply]
> The source code is
> 
>         if (nla_len(a) != sizeof(sizeof(struct in6_addr)))
> 
> I'm surprised that compiles. Suggest remove one of the sizeofs.

sizeof() resolves to a size_t value so... :)
