From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix using smp_processor_id() in
 preemptible code
Date: Sat, 14 Dec 2013 01:18:42 -0500 (EST)
Message-ID: <20131214.011842.785067168152054413.davem@davemloft.net>
References: <1386884395-12449-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhong@linux.vnet.ibm.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab3LNGSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:18:44 -0500
In-Reply-To: <1386884395-12449-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 12 Dec 2013 22:39:55 +0100

> From: Li Zhong <zhong@linux.vnet.ibm.com>
> 
> This patches fixes the following warning by replacing smp_processor_id()
> with raw_smp_processor_id():
 ...
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks everyone.
