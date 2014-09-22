From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 29/29] fm10k: Add support for PTP
Date: Mon, 22 Sep 2014 07:21:38 -0700
Message-ID: <54203072.5070701@intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com> <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com> <20140919173504.GA4136@localhost.localdomain> <063D6719AE5E284EB5DD2968C1650D6D174973B0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Richard Cochran' <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62831 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbaIVOVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 10:21:39 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174973B0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2014 04:03 AM, David Laight wrote:
> From: Of Richard Cochran
>> On Thu, Sep 18, 2014 at 06:40:46PM -0400, Alexander Duyck wrote:
>>
>>> +static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
>>> +			     struct fm10k_mbx_info *mbx)
>>> +{
>>> +	struct fm10k_intfc *interface = container_of(hw,
>>> +						     struct fm10k_intfc,
>>> +						     hw);
>>
>> This looks really funny to me here and in the other spot. Why not this?
>>
>> 	struct fm10k_intfc *interface = container_of(hw, struct fm10k_intfc, hw);
>>
>> Its only one over the 80 km/h speed limit.
> 
> Or split the assignment from the declaration.
> 
> 	David

That was the solution I went with.  It solved both the line over 80
characters and breaking up of the container_of parameter list.

Thanks,

Alex
