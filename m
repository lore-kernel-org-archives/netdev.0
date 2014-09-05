From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] ipv4: implement igmp_qrv sysctl to
 tune igmp robustness variable
Date: Thu, 04 Sep 2014 22:26:42 -0700 (PDT)
Message-ID: <20140904.222642.943899742529530912.davem@davemloft.net>
References: <3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
	<3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
	<b24ad902c532616c7683565df3a0fcc9d925da9c.1409665378.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbaIEF0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:26:43 -0400
In-Reply-To: <b24ad902c532616c7683565df3a0fcc9d925da9c.1409665378.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue,  2 Sep 2014 15:49:26 +0200

> As in IPv6 people might increase the igmp query robustness variable to
> make sure unsolicited state change reports aren't lost on the network. Add
> and document this new knob to igmp code.
> 
> RFCs allow tuning this parameter back to first IGMP RFC, so we also use
> this setting for all counters, including source specific multicast.
> 
> Also take over sysctl value when upping the interface and don't reuse
> the last one seen on the interface.
> 
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
