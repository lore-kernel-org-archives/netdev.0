From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to drvinfo
 and return it
Date: Fri, 26 Feb 2010 08:05:19 -0500
Message-ID: <4B87C70F.8060403@garzik.org>
References: <20100226115355.20213.59254.stgit@localhost.localdomain> <20100226.042027.250812962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42273 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936020Ab0BZNFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 08:05:22 -0500
Received: by gwj16 with SMTP id 16so18278gwj.19
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 05:05:21 -0800 (PST)
In-Reply-To: <20100226.042027.250812962.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2010 07:20 AM, David Miller wrote:
> From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> Date: Fri, 26 Feb 2010 03:54:20 -0800
>
>> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>>
>> The drvinfo struct should include the number of strings that
>> get_rx_ntuple will return.  It will be variable if an underlying
>> driver implements its own get_rx_ntuple routine, so userspace
>> needs to know how much data is coming.
>>
>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>
> Applied.

NAK.  Did you even read the patch?

We don't increase the size of struct ethtool_drvinfo, _especially_ by 
sticking struct members into the middle of the struct.

What do you think 'reserved' is for???

	Jeff



