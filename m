From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH,v2] Re: e1000e: why does pci_enable_pcie_error_reporting()
	fail on my hp2510p?
Date: Fri, 21 Aug 2009 00:01:51 -0700
Message-ID: <9929d2390908210001w10423b51mb460819bb59d7d77@mail.gmail.com>
References: <200908210829.10471.elendil@planet.nl> <4A8E3FC1.50201@redhat.com>
	 <200908210848.39377.elendil@planet.nl>
	 <20090820.235219.74114618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, dfeng@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:63029 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684AbZHUHBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 03:01:51 -0400
In-Reply-To: <20090820.235219.74114618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 23:52, David Miller<davem@davemloft.net> wrote:
> From: Frans Pop <elendil@planet.nl>
> Date: Fri, 21 Aug 2009 08:48:38 +0200
>
>> From: Frans Pop <elendil@planet.nl>
>> Subject: net: Don't report an error if devices don't support AER
>>
>> The only error returned by pci_{en,dis}able_pcie_error_reporting() is
>> -EIO which simply means that Advanced Error Reporting is not supported.
>> There is no need to report that, so remove the error check from e1001e,
>> igb and ixgbe.
>>
>> Signed-off-by: Frans Pop <elendil@planet.nl>
>
> Intel folks, just let me know what you want me to do with this,
> if anything.
>
> Thanks.
> --

I will add it to my queue of patches.  I would like to have Emil touch
test this patch at least before pushing the patch to Dave.

-- 
Cheers,
Jeff
