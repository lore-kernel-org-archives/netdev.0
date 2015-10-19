From: Jovi Zhangwei <jovi@cloudflare.com>
Subject: Re: kernel warning in tcp_fragment
Date: Mon, 19 Oct 2015 11:57:20 +0100
Message-ID: <CABPcSqJmKL7_FjAQHF4f0ysw5qi8xhyGEMxOBTQhU2L-iNXb=g@mail.gmail.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
	<20150727231947.GC2832181@devbig242.prn2.facebook.com>
	<CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
	<CABPcSqLWopootOwASY+KacoLM-G62iYfv+9VhJb0-MmQXtbYmQ@mail.gmail.com>
	<CADVnQy=-ADK-LVVhOC8Fs=z_1PiLjMSc4+z_qnKXu-wKx7Nq8g@mail.gmail.com>
	<20150813034528.GC2871239@devbig242.prn2.facebook.com>
	<55E62E89.3000204@fastly.com>
	<CABPcSqJMS3oYLbL=Ns71ciF_9rcZNuZ0VceV=noaLJgV=LTAQQ@mail.gmail.com>
	<CADVnQym84Qv-zrWatCGZcNBcNhXp68LrNCB9iVME=NxU6OYiTQ@mail.gmail.com>
	<CABPcSqJEoVAXk+PAZCWgD6LFV0Nxz7ON3CUuZZMgrcRQFLK44w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Zhang <gzhang@fastly.com>, Martin KaFai Lau <kafai@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>,
	Marek Majkowski <marek@cloudflare.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34954 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbbJSK5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 06:57:21 -0400
Received: by pasz6 with SMTP id z6so27642900pas.2
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 03:57:21 -0700 (PDT)
In-Reply-To: <CABPcSqJEoVAXk+PAZCWgD6LFV0Nxz7ON3CUuZZMgrcRQFLK44w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin and Eric,

Do we have a final solution or patch for this issue? There have so
many this warnings in our production systems.

Thank you very much.

On Tue, Oct 13, 2015 at 4:55 PM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> Hi all,
>
> Is there have final patch to fix this issue? Thanks.
>
> On Mon, Sep 14, 2015 at 7:15 PM, Neal Cardwell <ncardwell@google.com> wrote:
>>
>> On Mon, Sep 14, 2015 at 6:27 AM, Jovi Zhangwei <jovi@cloudflare.com>
>> wrote:
>> >
>> > Hi Near,
>> >
>> > After several days testing on your patch, our system crashed. Dmesg
>> > attached.
>>
>> Jovi -- Sorry about that... thank you for the testing and the data point.
>>
>> neal
>
>
