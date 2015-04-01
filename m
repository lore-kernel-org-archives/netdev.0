From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v10 3/7] ixgbe: Add a RETA
 query command to VF-PF channel API
Date: Wed, 01 Apr 2015 10:29:45 +0300
Message-ID: <551B9E69.7090700@cloudius-systems.com>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com> <1427740529-9605-4-git-send-email-vladz@cloudius-systems.com> <1427787327.2497.111.camel@jtkirshe-mobl> <87618083B2453E4A8714035B62D67992502896D2@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33063 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbbDAH3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 03:29:48 -0400
Received: by wixm2 with SMTP id m2so29345522wix.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 00:29:47 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D67992502896D2@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/01/15 02:55, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Jeff Kirsher
>> Sent: Tuesday, March 31, 2015 12:35 AM
>> Subject: Re: [Intel-wired-lan] [PATCH net-next v10 3/7] ixgbe: Add a RETA query command to VF-PF channel API
>>
>> On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
>>> Add this new command for 82599 and x540 devices only. Support for
>>> other devices
>>> will be added later.
>>>
>>> 82599 and x540 VFs and PF share the same RSS redirection table (RETA).
>>> Therefore we just return it for all VFs.
>>>
>>> For 82599 and x540 RETA table is an array of 32 registers (128 bytes)
>>> and the maximum number of registers that may be delivered in a single VF-PF channel command is
>>> 15. Therefore we will deliver the whole table in 3 steps: 12, 12 and 8 registers in
>>> each step correspondingly.
> The above paragraph no longer applies to this patch. Perhaps Jeff can strip it to avoid having to resend the
> patch just for the description.

Right. Thanks, Emil.
The "compression" implemented in v9 voids the issue above and indeed the 
last paragraph above should be stripped.
Jeff, let me know if u want me to respin the series with the fixed 
description in this patch.

thanks,
vlad

>
> Thanks,
> Emil
>
