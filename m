From: Ben Greear <greearb@candelatech.com>
Subject: Re: Should we report bus width/speed via ethtool?
Date: Wed, 05 Dec 2012 15:09:11 -0800
Message-ID: <50BFD417.7070306@candelatech.com>
References: <50BFBE05.7020408@candelatech.com> <20121205.173650.1310171220758794440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47144 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab2LEXJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 18:09:20 -0500
In-Reply-To: <20121205.173650.1310171220758794440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2012 02:36 PM, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Wed, 05 Dec 2012 13:35:01 -0800
>
>> It seems the only way to get the current pci-e bus speed & width
>> in ixgbe (and probably many other NICs) is by parsing output
>> of lspci -vvv.
>>
>> I'd personally find it easier if this info were available via
>> ethtool API.
>
> You could just as easily have ethtool determine the PCI device
> location (using existing facilities) and fetch the PCI-e info from the
> PCI sysfs files.

Any particular sysfs file?  I've been grubbing around in there
and I don't see anything that specifies bus width or speed..

Maybe it's some binary blob that needs decoding?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
