From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Thu, 14 Jan 2010 15:31:01 -0800
Message-ID: <4B4FA935.9080902@hp.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com> <20100114145633.4c2d4ac6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:41905 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab0ANXbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 18:31:07 -0500
In-Reply-To: <20100114145633.4c2d4ac6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>The CPU masks is set on a per device basis in the sysfs variable
>>/sys/class/net/<device>/rps_cpus.  This is a set of canonical bit maps for
>>each NAPI nstance of the device.  For example:
>>
>>echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus
> 
> 
> Why not make a kobject out of cpus which would add subdirectory.
> This would keep interface consistent with the one value per file
> semantic of sysfs.

Perhaps a question of po-tay-toe vs po-tah-toe, but which will be easier to deal 
with for say 128 or 256 "CPUs?"

rick jones
