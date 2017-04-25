From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 22:00:24 -0400
Message-ID: <e58fd7ee-1bd0-0cd5-ab15-c510ec4e70bd@mojatatu.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
 <20170424182054.116d1a99@cakuba.netronome.com>
 <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com,
        netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:38510 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979862AbdDYCA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 22:00:28 -0400
Received: by mail-it0-f49.google.com with SMTP id f187so5810503ite.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 19:00:28 -0700 (PDT)
In-Reply-To: <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 09:48 PM, Jamal Hadi Salim wrote:
> On 17-04-24 09:20 PM, Jakub Kicinski wrote:
>> On Mon, 24 Apr 2017 20:58:18 -0400, Jamal Hadi Salim wrote:
>>> On 17-04-24 02:32 PM, David Miller wrote:
>
>>> You have 3 TLVs, one of which is u8 that only allows use of 3 bits.
>>> The other is a u32 which allows only 20 bits to be set.
>>
>> I don't think we will ever reuse bits in a field which is called
>> MPLS_LABEL for anything else than an MPLS label.
>
> That is true. So maybe bad example. It also helps the mpls disector
> wont for example allow copying of more than 20 bits for a label.

Hrm. maybe I am wrong.
Lets say user sets all of the 8 bits in BOS,
what does setting
key_val->mpls_bos = nla_get_u8 do?

Same with the 20 bits for the label in the u32
or 3 bit bits in the u8 tc.

cheers,
jamal
