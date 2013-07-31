From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net_sched: info leak in atm_tc_dump_class()
Date: Wed, 31 Jul 2013 15:04:49 -0700 (PDT)
Message-ID: <20130731.150449.1217293911356333498.davem@davemloft.net>
References: <20130730102339.GA14869@elgon.mountain>
	<20130730111820.GA1646@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab3GaWEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 18:04:51 -0400
In-Reply-To: <20130730111820.GA1646@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 30 Jul 2013 13:18:20 +0200

> Tue, Jul 30, 2013 at 12:23:39PM CEST, dan.carpenter@oracle.com wrote:
>>The "pvc" struct has a hole after pvc.sap_family which is not cleared.
>>
>>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks.
