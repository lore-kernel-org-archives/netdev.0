From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 2/2] igb: Add Support for new i210/i211 devices.
Date: Fri, 11 May 2012 23:02:48 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6261884D53C@ORSMSX102.amr.corp.intel.com>
References: <1336723282-3130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336723282-3130-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120511.182735.63933163877487008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:65041 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911Ab2EKXCv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 19:02:51 -0400
In-Reply-To: <20120511.182735.63933163877487008.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, May 11, 2012 3:28 PM
>To: Kirsher, Jeffrey T
>Cc: Wyborny, Carolyn; netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 2/2] igb: Add Support for new i210/i211 devices.
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Fri, 11 May 2012 01:01:22 -0700
>
>> +s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
>> +{
>> +	s32 ret_val;
>> +
>> +	ret_val = igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
>> +
>> +	return ret_val;
>> +}
>
>Please, this is just unnecessary syntactic masterbation, simplify this
>to:
>
>s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
>{
>	return igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
>}
>
>And:
>
>> +void igb_release_nvm_i210(struct e1000_hw *hw)
>> +{
>> +
>> +	igb_release_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
>> +}
>
>Please get rid of that unnecessary empty line.
>
>I can really tell when someone is extremely careless when removing
>their debugging code, and I can almost guarentee that's what has
>happened here.

Yes, you're right.  Will fix ASAP.

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
