From: Jovi Zhangwei <jovi@cloudflare.com>
Subject: Re: kernel warning in tcp_fragment
Date: Thu, 13 Aug 2015 16:05:04 -0700
Message-ID: <CABPcSqKbMPjuwUSirQJ9BWwLp8eteCr85PnCbjjVcpgKbtnE2g@mail.gmail.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
	<20150727231947.GC2832181@devbig242.prn2.facebook.com>
	<CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
	<CABPcSqLWopootOwASY+KacoLM-G62iYfv+9VhJb0-MmQXtbYmQ@mail.gmail.com>
	<CADVnQy=-ADK-LVVhOC8Fs=z_1PiLjMSc4+z_qnKXu-wKx7Nq8g@mail.gmail.com>
	<20150813034528.GC2871239@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:34834 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbbHMXFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 19:05:06 -0400
Received: by lahi9 with SMTP id i9so34362983lah.2
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 16:05:04 -0700 (PDT)
In-Reply-To: <20150813034528.GC2871239@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Aug 12, 2015 at 8:45 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Mon, Aug 10, 2015 at 02:35:37PM -0400, Neal Cardwell wrote:
>> On Mon, Aug 10, 2015 at 2:10 PM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
>> >
>> > Ping?
>> >
>> > We saw a lot of this warnings in our production system. It would be
>> > great appreciate if someone can give us the fix on this warnings. :)
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
Our system need net.ipv4.tcp_mtu_probing, so we cannot set it to 0.
We are testing previous patch given by Neal, I will let you know the result.

Thanks.
