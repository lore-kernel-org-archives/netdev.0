From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Tue, 28 Oct 2014 21:40:21 -0700
Message-ID: <1414557621.631.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
	 <1414553435.631.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJVizFA_Tpf0FpyH0uoKZa4TMiBaNPmD_-5Z5+Vg+hV8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:37679 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbaJ2EkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 00:40:22 -0400
Received: by mail-pd0-f172.google.com with SMTP id r10so2187625pdi.17
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 21:40:21 -0700 (PDT)
In-Reply-To: <CAADnVQJVizFA_Tpf0FpyH0uoKZa4TMiBaNPmD_-5Z5+Vg+hV8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 21:17 -0700, Alexei Starovoitov wrote:
> On Tue, Oct 28, 2014 at 8:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2014-10-28 at 18:17 -0700, Alexei Starovoitov wrote:
> >
> >> Interesting! Are you trying to optimize some of such NIC drivers? ;)
> >
> > ??
> >
> >> but all of 10G+ and virtio won't apply, right?
> >
> >
> > Which 10G+ driver could not use this ?
> >
> > mlx4 patch would be :
> 
> right.
> but it's not a critical path for napi drivers. Why bother?

You probably are missing something.

This is a critical path, of course.

Try netperf -t TCP_RR for example.
