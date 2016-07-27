From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: perform temperature query in adapter
 regardless of its interface state
Date: Tue, 26 Jul 2016 23:20:30 -0700 (PDT)
Message-ID: <20160726.232030.1883209020880684696.davem@davemloft.net>
References: <1469565582-5984-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
	netdev@vger.kernel.org
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbcG0GUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 02:20:31 -0400
In-Reply-To: <1469565582-5984-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Tue, 26 Jul 2016 17:39:42 -0300

> The be2net driver performs fw temperature queries on be_worker() routine,
> which is executed each second for each be_adapter. There is a frequency
> threshold to avoid fw query to happens at each call to be_worker();
> instead, currently a fw query occurs once in 64 runs of the procedure.
> 
> Nevertheless, this fw temperature query is invoked only for adapters which
> interface is up, so we can see I/O errors on read of hwmon counters from
> userspace (from tools like lm-sensors) in case we have adapters' functions
> which interface is down.
> 
> This patch moves the fw query code to be invoked even if interface is down.
> No functional changes were introduced.
> 
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Applied.
