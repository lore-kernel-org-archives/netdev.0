From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
Date: Wed, 21 Jul 2010 13:23:46 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F18462F6@orsmsx508.amr.corp.intel.com>
References: <1279730431-17156-1-git-send-email-andy@greyhouse.net>
 <20100721165055.GE13188@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Wright <chrisw@sous-sol.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53794 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507Ab0GUUXr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:23:47 -0400
In-Reply-To: <20100721165055.GE13188@sequoia.sous-sol.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Chris Wright
>Sent: Wednesday, July 21, 2010 9:51 AM
>To: Andy Gospodarek
>Cc: netdev@vger.kernel.org; chrisw@sous-sol.org
>Subject: Re: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
>
>* Andy Gospodarek (andy@greyhouse.net) wrote:
>> Some ixgbe cards put an invalid VF device ID in the PCIe SR-IOV
>> capability.  The ixgbe driver is only valid for PFs or non SR-IOV
>> hardware.  It seems that the same problem could occur on igb hardware
>as
>> well, so if we discover we are trying to initialize a VF in
>ixbge_probe
>> or igb_probe, print an error and exit.
>>
>> Based on a patch for ixgbe from Chris Wright <chrisw@sous-sol.org>.
>>
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> Cc: Chris Wright <chrisw@sous-sol.org>
>
>Acked-by: Chris Wright <chrisw@sous-sol.org>
>
>Only seen this on ixgbe, but since the result there is a kernel panic
>makes sense to be defensive.
>
>thanks,
>-chris

Acked-by: Greg Rose <gregory.v.rose@intel.com>

Looks good, thanks.

- Greg

