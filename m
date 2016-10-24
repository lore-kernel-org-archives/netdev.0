From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched filters: fix notification of filter
 delete with proper handle
Date: Mon, 24 Oct 2016 07:28:35 -0400
Message-ID: <52a22009-ac8e-f90f-5713-ed508aec125e@mojatatu.com>
References: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
 <580D3A14.5010705@iogearbox.net> <20161024084858.GD2781@nanopsycho>
 <580DCE57.6070606@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34557 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756858AbcJXL2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 07:28:39 -0400
Received: by mail-yw0-f195.google.com with SMTP id u124so8800140ywg.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 04:28:38 -0700 (PDT)
In-Reply-To: <580DCE57.6070606@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-24 05:03 AM, Daniel Borkmann wrote:
> On 10/24/2016 10:48 AM, Jiri Pirko wrote:
>> Mon, Oct 24, 2016 at 12:30:44AM CEST, daniel@iogearbox.net wrote:
>>> On 10/23/2016 05:35 PM, Jamal Hadi Salim wrote:
>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> An actual commit message would be good especially if it's a fix
>>> for -net tree plus stable. Thanks.
>>
>> Also a "Fixes:" tag would be nice to have :)
>
> This kernel address leakage dates back to history tree:
>
> Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")

Was this from bitkeeper?
Unfortunately - I think this changed somewhere after inception of
tc, pre-git. But i cant find any way to trace that. So we could point a
finger and say this bug "has always been there from day one"
and we need a way to annotate that.

Also, please suggest a good commit message.
I could point to iproute2 patch or cutnpaste the novel i wrote
there.

cheers,
jamal
