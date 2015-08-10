From: Jovi Zhangwei <jovi@cloudflare.com>
Subject: Re: kernel warning in tcp_fragment
Date: Mon, 10 Aug 2015 11:10:05 -0700
Message-ID: <CABPcSqLWopootOwASY+KacoLM-G62iYfv+9VhJb0-MmQXtbYmQ@mail.gmail.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
	<20150727231947.GC2832181@devbig242.prn2.facebook.com>
	<CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33258 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbbHJSKH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 14:10:07 -0400
Received: by lbbsx3 with SMTP id sx3so16080368lbb.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 11:10:05 -0700 (PDT)
In-Reply-To: <CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping?

We saw a lot of this warnings in our production system. It would be
great appreciate if someone can give us the fix on this warnings. :)

On Fri, Jul 31, 2015 at 11:04 AM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> Hi Eric,
>
> Would you like share your thought on this bug? great thanks.
>
>
> On Mon, Jul 27, 2015 at 4:19 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>> On Wed, Jul 22, 2015 at 11:55:35AM -0700, Jovi Zhangwei wrote:
>>> Sorry for disturbing, our production system(3.14 and 3.18 stable
>>> kernel) have many tcp_fragment warnings,
>>> the trace is same as below one which you discussed before.
>>>
>>> https://urldefense.proofpoint.com/v1/url?u=http://comments.gmane.org/gmane.linux.network/365658&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=fQUME5h%2FYY3oZjXbnLC3z6TaEEcTBSCAji4PkNqFjq8%3D%0A&s=1527f3221a6f31cba9544e5ddaa20986aafe8be8c898b42c7e9ce5e68d3803d8
>>>
>>> But I didn't found the final solution in that mail thread, do you have
>>> any new ideas or patches on this warning?
>>
>> I think the following points to the last discussion.  We are currently using a
>> similar patch:
>> http://comments.gmane.org/gmane.linux.network/366549
>>
>> Eric, any update on your findings? or you have already pushed a fix?
>>
>> Thanks,
>> --Martin
