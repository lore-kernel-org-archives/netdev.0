From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH iproute2 net-next 1/2] iproute: Add support for
 ttl-propagation attribute
Date: Tue, 11 Apr 2017 09:35:53 +0100
Message-ID: <82d66079-17ed-b17e-4bac-a84e89c3d1d7@brocade.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
 <1491834972-26668-2-git-send-email-rshearma@brocade.com>
 <08e2c6b8-0910-0d0b-39a4-887a0d3e4f94@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52646 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753401AbdDKIgJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 04:36:09 -0400
In-Reply-To: <08e2c6b8-0910-0d0b-39a4-887a0d3e4f94@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/17 04:43, David Ahern wrote:
> On 4/10/17 8:36 AM, Robert Shearman wrote:
>> @@ -1184,6 +1192,20 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
>>
>>  			if (rta->rta_len > RTA_LENGTH(0))
>>  				addraw_l(&req.n, 1024, RTA_DATA(rta), RTA_PAYLOAD(rta));
>> +		} else if (strcmp(*argv, "ttl-propagate") == 0) {
>> +			__u8 ttl_prop;
>> +
>> +			NEXT_ARG();
>> +			if (strcmp(*argv, "enabled") == 0)
>> +				ttl_prop = 1;
>> +			else if (strcmp(*argv, "disabled") == 0)
>> +				ttl_prop = 0;
>> +			else
>> +				invarg("\"ttl-propagate\" value is invalid\n",
>> +				       *argv);
>> +
>
> matches() instead of strcmp() is more user friendly. 'enabled' is a lot
> to type. ;-)
>

Ok, will change as suggested in v2.

Thanks for reviewing,
Rob
