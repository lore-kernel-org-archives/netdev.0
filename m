From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v1 net-next 1/5] drop_monitor: import netnamespace framework
Date: Wed, 12 Jul 2017 10:45:52 -0700
Message-ID: <CAM_iQpXgKbHG5dL77d=yqarn_xJapVKv3z10Kzsn34vkKWUoTA@mail.gmail.com>
References: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
 <20170712133748.GA21036@hmswarspite.think-freely.org> <CAM_iQpVDns-WLagoiAxVCmkohm9+QJF1so60++K5Qef-qOFx=w@mail.gmail.com>
 <eef69f4a65644a499665d3973bf5bc06@BJSGEXMBX01.didichuxing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Neil Horman <nhorman@tuxdriver.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        martinbj2008 <martinbj2008@gmail.com>,
        David Miller <davem@davemloft.net>
To: =?UTF-8?B?5byg5Yab5LyfKOWfuuehgOW5s+WPsOmDqCk=?=
        <zhangjunweimartin@didichuxing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38278 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdGLRqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 13:46:13 -0400
Received: by mail-wm0-f53.google.com with SMTP id f67so1609150wmh.1
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 10:46:13 -0700 (PDT)
In-Reply-To: <eef69f4a65644a499665d3973bf5bc06@BJSGEXMBX01.didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 12, 2017 at 10:08 AM, =E5=BC=A0=E5=86=9B=E4=BC=9F(=E5=9F=BA=E7=
=A1=80=E5=B9=B3=E5=8F=B0=E9=83=A8)
<zhangjunweimartin@didichuxing.com> wrote:
> about skb->sk
> it is used as supplementary when skb->dev is empty=EF=BC=8Csuch as netlin=
k message=E3=80=82
>
> +       if (skb->dev)
> +               net =3D dev_net(skb->dev);
> +       else if (skb->sk)
> +               net =3D sock_net(skb->sk);
> +       else
> +               return;

Check udp_set_dev_scratch().

Again, as Neil mentioned, the idea is arguable, it is actually harder to tr=
ace
skb's with your patch when they across netns'es.
