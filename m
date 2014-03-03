From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_tbf: Remove holes in struct
 tbf_sched_data.
Date: Mon, 03 Mar 2014 15:44:08 -0500 (EST)
Message-ID: <20140303.154408.69108434699163216.davem@davemloft.net>
References: <20140302173026.ad5cd8c8447ddf8806b03651@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaCCUoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:44:09 -0500
In-Reply-To: <20140302173026.ad5cd8c8447ddf8806b03651@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Sun, 2 Mar 2014 17:30:26 +0900

> On x86_64 we have 3 holes in struct tbf_sched_data.
> 
> The member peak_present can be replaced with peak.rate_bytes_ps,
> because peak.rate_bytes_ps is set only when peak is specified in
> tbf_change(). tbf_peak_present() is introduced to test
> peak.rate_bytes_ps.
> 
> The member max_size is moved to fill 32bit hole.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

This looks fine, applied, thanks.
