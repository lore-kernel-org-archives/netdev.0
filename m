From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/3 v6] net: ether: Add support for multiplexing
 and aggregation type
Date: Mon, 21 Aug 2017 08:17:45 -0400
Message-ID: <39c75b3d-2662-0a26-7752-fbcf9eea2781@mojatatu.com>
References: <1503120931-30092-1-git-send-email-subashab@codeaurora.org>
 <1503120931-30092-2-git-send-email-subashab@codeaurora.org>
 <6dd2e0b7-51ec-18a3-07fb-3952a114b89a@mojatatu.com>
 <20170820.151207.1229905735989482121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, netdev@vger.kernel.org,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36150 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752234AbdHUMRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 08:17:48 -0400
Received: by mail-io0-f193.google.com with SMTP id o196so1043250ioe.3
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 05:17:48 -0700 (PDT)
In-Reply-To: <20170820.151207.1229905735989482121.davem@davemloft.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-20 06:12 PM, David Miller wrote:

>>> +#define ETH_P_MAP 0xDA1A /* Multiplexing and Aggregation Protocol
>>> + * NOT AN OFFICIALLY REGISTERED ID ]
>>
>> You cant just arbitrarly assign yourself an ethertype.  The IEEE may
>> never issue you one - and if they do, it will likely not be the one
>> you want i.e above.
>>
>> If there is a way for you to make this a config option that is not
>> hardcoded to some default value then that would be the best approach
>> to take.
> 
> This may be a kind of a different situation, these ethertypes exist
> only internally in the kernel and never on the wire.
> 
> It's just controlling the demux on ethernet receive.
> 
> We have several IDs like this, and thus this addition is consistent
> with existing practice.

Ok, so if the IEEE issued this ID to someone there will be no conflict
then?
I checked - all the ether types listed in the header file as
"NOT AN OFFICIALLY REGISTERED ID" are not currently assigned by IEEE.

cheers,
jamal
