From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 10/12] igb: move DMA Coalescing feature code into
 separate function.
Date: Wed, 12 Oct 2011 15:21:34 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F017D02550C@orsmsx508.amr.corp.intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318390708-12232-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20111012.164834.2208432778408483576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sowles, Jacob R" <jacob.r.sowles@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35043 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093Ab1JLWVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 18:21:35 -0400
In-Reply-To: <20111012.164834.2208432778408483576.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of David Miller
>Sent: Wednesday, October 12, 2011 1:49 PM
>To: Kirsher, Jeffrey T
>Cc: Sowles, Jacob R; netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 10/12] igb: move DMA Coalescing feature code into
>separate function.
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Tue, 11 Oct 2011 20:38:26 -0700
>
>> From: Jacob Sowles <jacob.r.sowles@intel.com>
>>
>> DMA Coalescing code needs to be executed during reset, if enabled.
>Moved
>> code to separate function and added a call to it in igb_reset.
>>
>> Signed-off-by: Jacob Sowles <jacob.r.sowles@intel.com>
>> Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
>Something is wrong here, this patch just adds the new function but no
>actual callers.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Yes, you are correct.  We had a problem in our process and this patch got inadvertently changed during it, removing a substantial part of it, including the call to the new function.  I'm on it and will be submitting a replacement as soon as possible.

Thanks,

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
