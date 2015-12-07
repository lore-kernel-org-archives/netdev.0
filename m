From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [PATCH v9] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Mon, 7 Dec 2015 14:00:13 -0800
Message-ID: <CAP-MU4MKSVeRGfJJqAo97QXLZmcxZykJt8n0cWKfTi_LHMJ7TA@mail.gmail.com>
References: <20151207200634.GA4415@oracle.com>
	<20151207.162802.462148155042537146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com,
	Andy Shevchenko <andy.shevchenko@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36266 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803AbbLGWAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 17:00:18 -0500
In-Reply-To: <20151207.162802.462148155042537146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Shannon Nelson <shannon.nelson@intel.com


On Mon, Dec 7, 2015 at 1:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Mon, 7 Dec 2015 15:06:34 -0500
>
>> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
>> address in Open Firmware or IDPROM").
>>
>> As with that fix, attempt to look up the MAC address in Open Firmware
>> on systems that support it, and use IDPROM on SPARC if no OF address
>> is found.
>>
>> In the case of the i40e there is an assumption that the default mac
>> address has already been set up as the primary mac filter on probe,
>> so if this filter is obtained from the Open Firmware or IDPROM, an
>> explicit write is needed via i40e_aq_mac_address_write() and
>> i40e_aq_add_macvlan() invocation.
>>
>> The I40E_FLAG_PF_MAC flag in the platform-private i40e_pf structure
>> tracks whether a platform-specific mac address was found, in which
>> case calls to i40e_aq_mac_address_write() and i40e_aq_add_macvlan()
>> will be triggered.
>>
>> Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
>> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>
> This looks good to me.
>
> Once this goes in I'll add my generic MAC stuff to net-next and then
> we can convert the various Intel drivers to use it.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
==============================================

Mr. Shannon Nelson                        Network Division, Intel Corp.

Shannon.Nelson@intel.com                I don't speak for Intel

                 Parents can't afford to be squeamish
