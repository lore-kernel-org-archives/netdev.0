From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [Intel-wired-lan] [jkirsher/next-queue PATCH v4 6/6] i40e: Enable
 cloud filters via tc-flower
Date: Thu, 26 Oct 2017 14:47:07 -0700
Message-ID: <27b531d3-39bf-2b08-1b0b-298689568315@intel.com>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
 <150768148418.5320.6338243543224569414.stgit@anamdev.jf.intel.com>
 <86d2bf80-cf02-9cc0-291d-c00ff39d613b@oracle.com>
 <888ad716-75c7-f1c0-439a-58fdeb9a7234@intel.com>
 <28335085-cc51-85a5-d602-4ae9d1e1088c@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shannon Nelson <shannon.nelson@oracle.com>,
        intel-wired-lan@osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8767 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932400AbdJZVrI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 17:47:08 -0400
In-Reply-To: <28335085-cc51-85a5-d602-4ae9d1e1088c@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2017 2:35 PM, Shannon Nelson wrote:
> On 10/26/2017 2:29 PM, Nambiar, Amritha wrote:
>> On 10/11/2017 4:30 PM, Shannon Nelson wrote:
>>> On 10/10/2017 5:24 PM, Amritha Nambiar wrote:
> 
> [...]
> 
>>>> +		/* For Geneve, the VNI should be placed in offset shifted by a
>>>> +		 * byte than the offset for the Tenant ID for rest of the
>>>
>>> This comment isn't quite clear - maybe s/than/then/ ?
>>
>> How about, "For Geneve, the VNI should begin at an offset shifted by a
>> byte compared to the offset normally used for the Tenant ID for other
>> tunnel types" ?
> 
> Or maybe "Due to hardware eccentricities, the VNI for Geneve is shifted 
> one more byte further than normally used for Tenant ID in other tunnel 
> types"

Will do. Thanks.

> 
> [...]
> 
>>>> +				dev_err(&pf->pdev->dev, "Bad src port mask 0x%04x\n",
>>>
>>> Consider using %pI4
>>
>> For ports, I'll keep the 0x%04x. I'll change to %pI4 for the IPv4
>> address masks.
> 
> Oh, right, that one's a port.
> 
> sln
> 
