From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 21:25:27 -0400
Message-ID: <21a6a034-31e2-b74e-731c-33f2e41f6546@mojatatu.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
 <20170425010558.GC24425@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        bcrl@kvack.org, Jiri Pirko <jiri@resnulli.us>
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33653 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979686AbdDYBZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 21:25:36 -0400
Received: by mail-io0-f171.google.com with SMTP id k87so207772776ioi.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 18:25:35 -0700 (PDT)
In-Reply-To: <20170425010558.GC24425@nvt-d.home.kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 09:05 PM, Benjamin LaHaise wrote:
> On Mon, Apr 24, 2017 at 08:58:18PM -0400, Jamal Hadi Salim wrote:
>> On 17-04-24 02:32 PM, David Miller wrote:

>> You have 3 TLVs, one of which is u8 that only allows use of 3 bits.
>> The other is a u32 which allows only 20 bits to be set.
>
> What are the new rules for TLVs -- do you want a new type added for the
> subset values that are limited to the number of bits actually used?  A
> pointed here would be helpful.
>

The rules are to check for bits that are not used.
For example in the BOS TLV it would be required to
verify that the user did not set any other bit other than the
bos field. It is required to reject the whole thing if the user
set any other of the u8 bits.

cheers,
jamal
