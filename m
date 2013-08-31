From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] qdisc: fix build with !CONFIG_NET_SCHED
Date: Sat, 31 Aug 2013 18:10:40 -0400 (EDT)
Message-ID: <20130831.181040.1667925431686550107.davem@davemloft.net>
References: <20130831100442.60c99dc8@nehalam.linuxnetplumber.net>
	<20130831101533.6cb8e452@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913Ab3HaWKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 18:10:41 -0400
In-Reply-To: <20130831101533.6cb8e452@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 31 Aug 2013 10:15:33 -0700

> Multiqueue scheduler refers to default_qdisc_ops; therefore the
> variable definition needs to be moved to handle case where net
> scheduler API is not available.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
