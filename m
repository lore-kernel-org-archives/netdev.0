From: David Daney <david.daney@cavium.com>
Subject: Re: [net-next v2 48/71] octeon: Move the Cavium driver
Date: Tue, 02 Aug 2011 15:48:20 -0700
Message-ID: <4E387EB4.3080000@cavium.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com> <1312082850-24914-49-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, David Daney <ddaney@caviumnetworks.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:12052 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349Ab1HBWs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 18:48:27 -0400
In-Reply-To: <1312082850-24914-49-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2011 08:27 PM, Jeff Kirsher wrote:
> Move the Cavium driver to drivers/net/ethernet/octeon/ and
> make the necessary Kconfig and Makefile changes.
>
> CC: David Daney<ddaney@caviumnetworks.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>

Acked-by: <david.daney@cavium.com>

I haven't tested the patch, but it looks good to me.  I will fix any 
breakage that may occur after the patch is merged.

Thanks.
David Daney

> ---
>   drivers/net/Kconfig                             |    2 --
>   drivers/net/Makefile                            |    1 -
>   drivers/net/ethernet/Kconfig                    |    1 +
>   drivers/net/ethernet/Makefile                   |    1 +
>   drivers/net/{ =>  ethernet}/octeon/Kconfig       |    0
>   drivers/net/{ =>  ethernet}/octeon/Makefile      |    0
>   drivers/net/{ =>  ethernet}/octeon/octeon_mgmt.c |    0
>   7 files changed, 2 insertions(+), 3 deletions(-)
>   rename drivers/net/{ =>  ethernet}/octeon/Kconfig (100%)
>   rename drivers/net/{ =>  ethernet}/octeon/Makefile (100%)
>   rename drivers/net/{ =>  ethernet}/octeon/octeon_mgmt.c (100%)
>
