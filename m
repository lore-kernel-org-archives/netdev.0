From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next 13/18] switchdev: remove unused NETIF_F_HW_SWITCH_OFFLOAD
Date: Mon, 30 Mar 2015 13:48:34 -0700
Message-ID: <5519B6A2.4040204@intel.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com> <1427704836-8776-14-git-send-email-sfeldma@gmail.com> <551951CD.1060301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com
To: roopa <roopa@cumulusnetworks.com>, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:51910 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029AbbC3Usf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 16:48:35 -0400
In-Reply-To: <551951CD.1060301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/2015 6:38 AM, roopa wrote:
> On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Flag is no longer needed so remove it.  Using the attr get/set 
>> recurse algo
>> obsoletes the flag.  Setting the flag on bond/team interface, even 
>> when the
>> consitient member ports didn't have flag set was confusing.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> The flag was there to avoid the recursive lowerdev walk where possible.
> bond will have the flag if any one slave can have it. You don't walk 
> the bond if it does not have the flag.
> Also, this allows the user to disable the feature from userspace if 
> required and move everything to software.
>
I was also planning to use this flag to enable lowerdev walk for fdb 
add/delete on a team device with switchdev
member ports and not attached to a bridge.
Will submit a RFC patch for review.

Thanks
Sridhar
