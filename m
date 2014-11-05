From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] geneve: Set GSO type on transmit.
Date: Wed, 05 Nov 2014 15:01:12 -0500 (EST)
Message-ID: <20141105.150112.2773315494340024.davem@davemloft.net>
References: <1415072318-64442-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, azhou@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaKEUBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:14 -0500
In-Reply-To: <1415072318-64442-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon,  3 Nov 2014 19:38:37 -0800

> Geneve does not currently set the inner protocol type when
> transmitting packets. This causes GSO segmentation to fail on NICs
> that do not support Geneve offloading.
> 
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
