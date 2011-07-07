From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: round down # of queues to power of two
Date: Wed, 6 Jul 2011 18:08:39 -0700
Message-ID: <201107061808.39918.dtor@vmware.com>
References: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	yongwang@vmware.com
To: pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:4094 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751857Ab1GGBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 21:08:40 -0400
Received: from mailhost2.vmware.com (mailhost2.vmware.com [10.16.67.167])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 2E1E131008
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2011 18:08:40 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, July 06, 2011 05:58:51 PM Shreyas Bhatewara wrote:

> 
> +	if (!is_power_of_2(num_rx_queues))
> +		num_rx_queues = rounddown_pow_of_two(num_rx_queues);
> +

No need to do the check, just do:

	num_rx_queues = rounddown_pow_of_two(num_rx_queues);

Thanks,
Dmitry
