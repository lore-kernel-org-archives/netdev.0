From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: remove device ID for unsupported device
Date: Wed, 23 Jul 2008 09:05:20 -0700
Message-ID: <9929d2390807230905r68bbba16wf5a593f4c61c239b@mail.gmail.com>
References: <20080712003458.21801.63058.stgit@localhost.localdomain>
	 <48866DC7.5000801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, gregkh@suse.de, davem@davemloft.net,
	netdev@vger.kernel.org,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:58918 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbYGWQFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 12:05:21 -0400
Received: by py-out-1112.google.com with SMTP id p76so1783008pyb.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 09:05:21 -0700 (PDT)
In-Reply-To: <48866DC7.5000801@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 4:31 PM, Jeff Garzik <jeff@garzik.org> wrote:
> Jeff Kirsher wrote:
>>
>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>
>> The ixgbe driver was untested with device ID 8086:10c8 but still
>> advertises
>> support.  Currently if this device is present in the system when the
>> driver
>> is loaded, the system will panic.
>> Remove this device ID until full support can be tested with available
>> hardware.  This patch is necessary for 2.6.24, 2.6.25 and 2.6.26
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>>  drivers/net/ixgbe/ixgbe_main.c |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>
> applied
>
>

Thanks.

-- 
Cheers,
Jeff
