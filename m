From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v4 0/2] l2 hardware accelerated macvlans
Date: Thu, 07 Nov 2013 19:31:16 -0800
Message-ID: <527C5B04.3050502@intel.com>
References: <20131106175308.3822.73239.stgit@jf-dev1-dcblab> <20131107.191244.1462002095786588675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, alexander.h.duyck@intel.com,
	andy@greyhouse.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59123 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884Ab3KHDbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 22:31:17 -0500
In-Reply-To: <20131107.191244.1462002095786588675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/2013 4:12 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Wed, 06 Nov 2013 09:54:40 -0800
>
>> This patch adds support to offload macvlan net_devices to the
>> hardware. With these patches packets are pushed to the macvlan
>> net_device directly and do not pass through the lower dev.
>
> Series applied, looks great.
>
> Thanks.
>

Thanks Dave. kbuild test robot reminds me that real_num_rx_queues is
only around with CONFIG_RPS. I'll get you a fix tonight.

.John
