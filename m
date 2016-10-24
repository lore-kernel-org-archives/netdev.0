From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/1] net sched filters: fix notification of filter
 delete with proper handle
Date: Mon, 24 Oct 2016 13:34:37 +0200
Message-ID: <580DF1CD.3070403@iogearbox.net>
References: <1477236912-5789-1-git-send-email-jhs@emojatatu.com> <580D3A14.5010705@iogearbox.net> <20161024084858.GD2781@nanopsycho> <580DCE57.6070606@iogearbox.net> <52a22009-ac8e-f90f-5713-ed508aec125e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33624 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755951AbcJXLem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 07:34:42 -0400
In-Reply-To: <52a22009-ac8e-f90f-5713-ed508aec125e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2016 01:28 PM, Jamal Hadi Salim wrote:
> On 16-10-24 05:03 AM, Daniel Borkmann wrote:
>> On 10/24/2016 10:48 AM, Jiri Pirko wrote:
>>> Mon, Oct 24, 2016 at 12:30:44AM CEST, daniel@iogearbox.net wrote:
>>>> On 10/23/2016 05:35 PM, Jamal Hadi Salim wrote:
>>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>>
>>>> An actual commit message would be good especially if it's a fix
>>>> for -net tree plus stable. Thanks.
>>>
>>> Also a "Fixes:" tag would be nice to have :)
>>
>> This kernel address leakage dates back to history tree:
>>
>> Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
>
> Was this from bitkeeper?
> Unfortunately - I think this changed somewhere after inception of
> tc, pre-git. But i cant find any way to trace that. So we could point a
> finger and say this bug "has always been there from day one"
> and we need a way to annotate that.

I guess saying that is okay too, commit is from history museum here:
https://git.kernel.org/cgit/linux/kernel/git/history/history.git/

> Also, please suggest a good commit message.
> I could point to iproute2 patch or cutnpaste the novel i wrote
> there.

I did the analysis already in: http://patchwork.ozlabs.org/patch/683863/
I don't mind if you want to take most parts of it.
