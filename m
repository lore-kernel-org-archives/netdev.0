From: Jovi Zhangwei <jovi@cloudflare.com>
Subject: Re: kernel warning in tcp_fragment
Date: Mon, 10 Aug 2015 14:53:11 -0700
Message-ID: <CABPcSq+iDwk3x-HgZiGd9qwg4dPiirx86qWWwhJxRT5-C6vxQQ@mail.gmail.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
	<20150727231947.GC2832181@devbig242.prn2.facebook.com>
	<CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
	<CABPcSqLWopootOwASY+KacoLM-G62iYfv+9VhJb0-MmQXtbYmQ@mail.gmail.com>
	<CADVnQy=-ADK-LVVhOC8Fs=z_1PiLjMSc4+z_qnKXu-wKx7Nq8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36860 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933583AbbHJVxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:53:13 -0400
Received: by lbbpu9 with SMTP id pu9so75408652lbb.3
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 14:53:12 -0700 (PDT)
In-Reply-To: <CADVnQy=-ADK-LVVhOC8Fs=z_1PiLjMSc4+z_qnKXu-wKx7Nq8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal,

Great thanks for your reply, we will arrange testing against that patch.

On Mon, Aug 10, 2015 at 11:35 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Mon, Aug 10, 2015 at 2:10 PM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
>>
>> Ping?
>>
>> We saw a lot of this warnings in our production system. It would be
>> great appreciate if someone can give us the fix on this warnings. :)
>
> What is your net.ipv4.tcp_mtu_probing setting? If 1, have you tried
> setting it to 0? Previous reports (
> https://patchwork.ozlabs.org/patch/480882/ ) have shown that this gets
> rid of at least one source of the warning. So that would provide a
> useful data point.
>
> Separately, you could also try the attached patch. This is against
> 3.14.39. It tries to attack a different possible source of this
> warning. Please let us know if that patch helps.
>
> Thanks!
>
> neal
