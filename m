From: Grant Zhang <gzhang@fastly.com>
Subject: Re: kernel warning in tcp_fragment
Date: Tue, 1 Sep 2015 16:02:33 -0700
Message-ID: <55E62E89.3000204@fastly.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
 <20150727231947.GC2832181@devbig242.prn2.facebook.com>
 <CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
 <CABPcSqLWopootOwASY+KacoLM-G62iYfv+9VhJb0-MmQXtbYmQ@mail.gmail.com>
 <CADVnQy=-ADK-LVVhOC8Fs=z_1PiLjMSc4+z_qnKXu-wKx7Nq8g@mail.gmail.com>
 <20150813034528.GC2871239@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>,
	Jovi Zhangwei <jovi@cloudflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34342 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbbIAXCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 19:02:37 -0400
Received: by padhy1 with SMTP id hy1so10174359pad.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 16:02:36 -0700 (PDT)
In-Reply-To: <20150813034528.GC2871239@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

I did try out your v2 patch on our production server and can confirm 
that the patch gets rid of the WARN_ON trace.

I would really like to see the issue been fixed by upstream(and 
backported to kernel longterm tree 3.14)--either by this patch or 
something else. Is there a plan for this?

Thanks,

Grant

On 12/08/2015 20:45, Martin KaFai Lau wrote:
> On Mon, Aug 10, 2015 at 02:35:37PM -0400, Neal Cardwell wrote:
>> On Mon, Aug 10, 2015 at 2:10 PM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
>>>
>>> Ping?
>>>
>>> We saw a lot of this warnings in our production system. It would be
>>> great appreciate if someone can give us the fix on this warnings. :)
>>
>> What is your net.ipv4.tcp_mtu_probing setting? If 1, have you tried
>> setting it to 0?
>
> Hi Jovi, If setting net.ipv4.tcp_mtu_probing=0 helps, can you give the
> patch we posted earlier a try: https://patchwork.ozlabs.org/patch/481609/
> It is the same patch that I pointed out earlier. You can click
> on the download link.
>
> We are currently using a similar patch while keeping net.ipv4.tcp_mtu_probing=1.
>
> Thanks,
> --Martin
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
