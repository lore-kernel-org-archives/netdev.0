From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched ife action: fix encoding to use real
 length
Date: Mon, 22 Aug 2016 07:00:54 -0400
Message-ID: <592c8a26-ff5d-388c-e49b-2e10394e7e50@mojatatu.com>
References: <1471601860-3336-1-git-send-email-jhs@emojatatu.com>
 <42438a9c-fe2f-3699-89e9-dc4d59250eba@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, mrv@mojatatu.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35260 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbcHVLBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:01:02 -0400
Received: by mail-io0-f195.google.com with SMTP id q83so8682284iod.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:01:02 -0700 (PDT)
In-Reply-To: <42438a9c-fe2f-3699-89e9-dc4d59250eba@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-19 09:22 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 8/19/2016 1:17 PM, Jamal Hadi Salim wrote:
>
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Encoding of the metadata was using the padded length as opposed to
>> the real length of the data which is a bug per specification.
>> This has not been an issue todate because all metadatum specified
>
>    To date? Metadata perhaps?
>

Todate as in "up to today".

>> so far has been 32 bit where aligned and data length are the same width.
>> This also includes a bug fix for validating the length of a u16 field.
>> But since there is no metadata of size u16 yes we are fine to include it
>> here.
>>
>> While at it get rid of magic numbers
>>
>> Fixes: ef6980b6
>
>    This tag has a standardized format, including 12-digit SHA1 and the
> commit summary enclosed in ("").
>

Ok, let me fix that and resend.

cheers,
jamal
