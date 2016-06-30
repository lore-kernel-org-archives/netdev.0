From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Thu, 30 Jun 2016 16:26:31 -0700
Message-ID: <CAM_iQpVOVKyyGLqvSzB9L1Dugo_zXdrc0Qymy_gBVNMTPm-sHw@mail.gmail.com>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
 <57757823.4090000@iogearbox.net> <CAM_iQpXtOr+AD2_q1E_dZm8MmLFAhdqPb6-_3ChgCr38gKi0yg@mail.gmail.com>
 <5775A710.9010105@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <tom@herbertland.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33464 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcF3Xcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:32:53 -0400
Received: by mail-qk0-f176.google.com with SMTP id o76so61409036qke.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 16:32:53 -0700 (PDT)
In-Reply-To: <5775A710.9010105@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 4:11 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 07/01/2016 12:42 AM, Cong Wang wrote:
>>
>> On Thu, Jun 30, 2016 at 12:50 PM, Daniel Borkmann <daniel@iogearbox.net>
>> wrote:
>>>
>>>
>>> Maybe makes sense to move skb_push_rcsum() but /also/ skb_pull_rcsum()
>>> to the header then? Both seem similarly small at least (could be split
>>> f.e into two patches then, first for the move, second for the actual
>>> fix).
>>
>>
>> No objection from me. Please feel free to send a patch. ;)
>
>
> Shrug, I actually meant this as feedback to your patch, since you move that
> helper and not as a note to myself. ;)

Interesting, my patch only moves what it needs, why does it need
to do more?

Again, I am not against your idea, just 1) it doesn't belong to my patch
2) I am too lazy to create a patch for it, or, I am perfectly fine with not
moving it too ;)
