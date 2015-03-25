From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next v7 3/7] ixgbe: Add a RETA query command to
 VF-PF channel API
Date: Wed, 25 Mar 2015 19:33:14 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250275E65@FMSMSX105.amr.corp.intel.com>
References: <1427202346-12502-1-git-send-email-vladz@cloudius-systems.com>
 <1427202346-12502-4-git-send-email-vladz@cloudius-systems.com>
 <87618083B2453E4A8714035B62D6799250275A68@FMSMSX105.amr.corp.intel.com>
 <55130AD2.4010509@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:38431 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbbCYTdR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:33:17 -0400
In-Reply-To: <55130AD2.4010509@cloudius-systems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com] 
>Sent: Wednesday, March 25, 2015 12:22 PM
>To: Tantilov, Emil S; netdev@vger.kernel.org
>Cc: Kirsher, Jeffrey T; avi@cloudius-systems.com; gleb@cloudius-systems.com
>Subject: Re: [PATCH net-next v7 3/7] ixgbe: Add a RETA query command to VF-PF channel API
>
>
>
>>On 03/25/15 20:03, Tantilov, Emil S wrote:


	<snip>
	
>>There is no need to query the X550 info through the mailbox - this information can be obtained directly from the VF registers.
>
>Unfortunately I couldn't find a x550 spec anywhere. Could u give me a pointer to it? 

There is no official documentation for X550 out yet AFAIK, but you can see how the RSS key and redirection table are populated in ixgbevf - ixgbevf_setup_vfmrqc(). Basically the info is in the IXGBE_VFRSSRK/RETA registers.

Or you can just strip the X550 related code from your patches and we'll take care of it once we agree on the implementation.

Thanks,
Emil
