From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: add memory limitation per queue
Date: Sun, 8 May 2016 22:07:16 -0700
Message-ID: <CAM_iQpXOTjdY4AsQVV6qz_U7be6m6OnYO0ZNSanxo6pXqdOu+Q@mail.gmail.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
 <865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com> <1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
 <C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com> <1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA93jw4XZ1+LLX1z6wQ6DHsp4vFCS5zmMz-uku_8SBNG_KuUxA@mail.gmail.com>
 <542135C7-D7CC-4E33-B35B-C2AD259FA5AB@gmx.de> <20160506133323.0b190f47@redhat.com>
 <D29AB9B2-D514-4D14-9A16-CFB9ECD05B17@gmx.de> <1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUfJxMxQXia8JOH5xouSFMThrdZWZMUuQ0q=bSmp8oEEQ@mail.gmail.com> <1462768295.23934.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	=?UTF-8?Q?Dave_T=C3=A4ht?= <dave.taht@gmail.com>,
	netdev <netdev@vger.kernel.org>, moeller0 <moeller0@gmx.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:33451 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbcEIFHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 01:07:36 -0400
Received: by mail-yw0-f176.google.com with SMTP id t10so275287296ywa.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 22:07:36 -0700 (PDT)
In-Reply-To: <1462768295.23934.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 9:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-05-08 at 21:14 -0700, Cong Wang wrote:
>
>> So when the packet is dropped due to memory over limit, should
>> we return failure for this case? Or I miss anything?
>
> Same behavior than before.
>
> If we dropped some packets of this flow, we return NET_XMIT_CN

I think for the limited memory case, the upper layer is supposed
to stop sending more packets when hitting the limit.
