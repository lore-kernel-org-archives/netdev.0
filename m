From: roprabhu <roprabhu@cisco.com>
Subject: Re: [PATCH] iproute2: add VF_PORT support
Date: Tue, 09 Nov 2010 15:30:29 -0800
Message-ID: <C8FF1995.188E2%roprabhu@cisco.com>
References: <20101109142219.0166576a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <chrisw@redhat.com>,
	<scofeldm@cisco.com>, <arnd@arndb.de>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62796 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab0KIXbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 18:31:32 -0500
In-Reply-To: <20101109142219.0166576a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 11/9/10 2:22 PM, "Stephen Hemminger" <shemminger@vyatta.com> wrote:

> On Tue, 09 Nov 2010 14:20:11 -0800
> Roopa Prabhu <roprabhu@cisco.com> wrote:
> 
>> response == PORT_VDP_RESPONSE_SUCCESS ?
>> +    "SUCCESS" :
>> +   response == PORT_VDP_RESPONSE_INVALID_FORMAT ?
>> +    "INVALID FORMAT" :
>> +   response == PORT_VDP_RESPONSE_INSUFFICIENT_RESOURCES ?
>> +    "INSUFFICIENT RESOURCES" :
>> +   response == PORT_VDP_RESPONSE_UNUSED_VTID ?
>> +    "UNUSED VTID" :
>> +   response == PORT_VDP_RESPONSE_VTID_VIOLATION ?
>> +    "VTID VIOLATION" :
>> +   response == PORT_VDP_RESPONSE_VTID_VERSION_VIOALTION ?
>> +    "VTID VERSION VIOLATION" :
>> +   response == PORT_VDP_RESPONSE_OUT_OF_SYNC ?
>> +    "OUT-OF-SYNC" :
>> +   response == PORT_PROFILE_RESPONSE_SUCCESS ?
>> +    "SUCCESS" :
>> +   response == PORT_PROFILE_RESPONSE_INPROGRESS ?
>> +    "IN-PROGRESS" :
>> +   response == PORT_PROFILE_RESPONSE_INVALID ?
>> +    "INVALID" :
>> +   response == PORT_PROFILE_RESPONSE_BADSTATE ?
>> +    "BAD STATE" :
>> +   response == PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES ?
>> +    "INSUFFICIENT RESOURCES" :
>> +   response == PORT_PROFILE_RESPONSE_ERROR ?
>> +    "ERROR" :
>> +   "UNKNOWN RESPONSE");
> 
> That's an ugly way to do this.
> Make it a real function nor array.

Ok sounds good. Will re-spin. Thanks.

