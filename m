From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: kernel warning in tcp_fragment
Date: Mon, 14 Sep 2015 11:12:02 -0700
Message-ID: <20150914181202.GA65794@kafai-mba.gkf168.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
 <20150727231947.GC2832181@devbig242.prn2.facebook.com>
 <CABPcSqLJz33sQ9a_-g9oi7i=fxkBSXga9aSs3X2CJ_Xb2xVSOg@mail.gmail.com>
 <CABPcSqLWopootOwASY+KacoLM-G62iYfv+9VhJb0-MmQXtbYmQ@mail.gmail.com>
 <CADVnQy=-ADK-LVVhOC8Fs=z_1PiLjMSc4+z_qnKXu-wKx7Nq8g@mail.gmail.com>
 <20150813034528.GC2871239@devbig242.prn2.facebook.com>
 <55E62E89.3000204@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jovi Zhangwei <jovi@cloudflare.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41789 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198AbbINSMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 14:12:43 -0400
Content-Disposition: inline
In-Reply-To: <55E62E89.3000204@fastly.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

Thanks for testing it.  I will try to repost the patch.

Thanks,
Martin

On Tue, Sep 01, 2015 at 04:02:33PM -0700, Grant Zhang wrote:
> Hi Martin,
>
> I did try out your v2 patch on our production server and can confirm that
> the patch gets rid of the WARN_ON trace.
>
> I would really like to see the issue been fixed by upstream(and backported
> to kernel longterm tree 3.14)--either by this patch or something else. Is
> there a plan for this?
>
> Thanks,
>
> Grant
>
> On 12/08/2015 20:45, Martin KaFai Lau wrote:
> >On Mon, Aug 10, 2015 at 02:35:37PM -0400, Neal Cardwell wrote:
> >>On Mon, Aug 10, 2015 at 2:10 PM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> >>>
> >>>Ping?
> >>>
> >>>We saw a lot of this warnings in our production system. It would be
> >>>great appreciate if someone can give us the fix on this warnings. :)
> >>
> >>What is your net.ipv4.tcp_mtu_probing setting? If 1, have you tried
> >>setting it to 0?
> >
> >Hi Jovi, If setting net.ipv4.tcp_mtu_probing=0 helps, can you give the
> >patch we posted earlier a try: https://urldefense.proofpoint.com/v1/url?u=https://patchwork.ozlabs.org/patch/481609/&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=wYNHn6ACXUwYfYQpS2rAg%2BLrj8CrcyDTTr3Fx5SFoWg%3D%0A&s=51041d4fd18fa1568b4b46b683640d8239be657c50af324621ba9a4e8c9a96b6
> >It is the same patch that I pointed out earlier. You can click
> >on the download link.
> >
> >We are currently using a similar patch while keeping net.ipv4.tcp_mtu_probing=1.
> >
> >Thanks,
> >--Martin
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
