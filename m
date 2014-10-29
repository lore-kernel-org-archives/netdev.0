From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Tue, 28 Oct 2014 21:17:39 -0700
Message-ID: <CAADnVQJVizFA_Tpf0FpyH0uoKZa4TMiBaNPmD_-5Z5+Vg+hV8Q@mail.gmail.com>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
	<1414553435.631.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:42455 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaJ2ERk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 00:17:40 -0400
Received: by mail-qc0-f174.google.com with SMTP id r5so1734261qcx.19
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 21:17:39 -0700 (PDT)
In-Reply-To: <1414553435.631.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 8:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-10-28 at 18:17 -0700, Alexei Starovoitov wrote:
>
>> Interesting! Are you trying to optimize some of such NIC drivers? ;)
>
> ??
>
>> but all of 10G+ and virtio won't apply, right?
>
>
> Which 10G+ driver could not use this ?
>
> mlx4 patch would be :

right.
but it's not a critical path for napi drivers. Why bother?
