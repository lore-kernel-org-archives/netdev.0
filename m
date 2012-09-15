From: Yuchung Cheng <ycheng@google.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Sat, 15 Sep 2012 11:16:52 -0700
Message-ID: <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
References: <20120905043523.GA12988@redhat.com> <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
 <20120914212958.GA25053@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:53282 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661Ab2IOSRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 14:17:13 -0400
Received: by oago6 with SMTP id o6so3715051oag.19
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2012 11:17:13 -0700 (PDT)
In-Reply-To: <20120914212958.GA25053@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 14, 2012 at 2:29 PM, Dave Jones <davej@redhat.com> wrote:
> On Wed, Sep 05, 2012 at 11:48:29PM +0300, Julian Anastasov wrote:
>
>  > > kernel BUG at kernel/timer.c:748!
>  > > Call Trace:
>  > >  ? lock_sock_nested+0x8d/0xa0
>  > >  sk_reset_timer+0x1c/0x30
>  > >  ? sock_setsockopt+0x8c/0x960
>  > >  inet_csk_reset_keepalive_timer+0x20/0x30
>  > >  tcp_set_keepalive+0x3d/0x50
>  > >  sock_setsockopt+0x923/0x960
>  > >  ? trace_hardirqs_on_caller+0x16/0x1e0
>  > >  ? fget_light+0x24c/0x520
>  > >  sys_setsockopt+0xc6/0xe0
>  > >  system_call_fastpath+0x1a/0x1f
>  >
>  >      Can this help? In case you see ICMPV6_PKT_TOOBIG...
>  >
>  > [PATCH] tcp: fix possible socket refcount problem for ipv6
>
> I just managed to reproduce this bug on rc5 with this patch,
> so it doesn't seem to help.
Could you post some tcpdump traces?

>
>         Dave
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
