From: Lorenzo Colitti <lorenzo@google.com>
Subject: =?UTF-8?Q?Re=3A_linux_kernel_=E2=80=93_4=2E4=2E45_=3A_VPN_test_failure?=
Date: Thu, 26 Oct 2017 09:39:27 +0900
Message-ID: <CAKD1Yr0wRge5Xk453iaNUx4k4=q5iUDc-X2a=9gBwR5nuwuO2g@mail.gmail.com>
References: <5fae6d9bd62e42acb24a7a8cfdcc8a86@HIBDWSMB01.ad.harman.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "amit.pundir@linaro.org" <amit.pundir@linaro.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
        "g.nault@alphalink.fr" <g.nault@alphalink.fr>,
        "jiri@mellanox.com" <jiri@mellanox.com>
To: "Nanjappa, Gangadhar" <Gangadhar.Nanjappa@harman.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:50276 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZAjs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 20:39:48 -0400
Received: by mail-it0-f45.google.com with SMTP id 72so3251039itl.5
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 17:39:48 -0700 (PDT)
In-Reply-To: <5fae6d9bd62e42acb24a7a8cfdcc8a86@HIBDWSMB01.ad.harman.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 9:49 PM, Nanjappa, Gangadhar
<Gangadhar.Nanjappa@harman.com> wrote:
> Using linux kernel =E2=80=93 4.4.45 (Blurry Fish Butt), VPN test fails. I=
f I revert
> the attached five patches, VPN test passes.
> [...]
>
> 1.       1-net-core-add-UID-to-flows-rules-and-routes.patch

Those patches don't exist in 4.4, they were merged in 4.10. It looks
like this is an Android-specific test. The easiest way to resolve this
issue is to run the Android networking unit tests:

https://source.android.com/devices/architecture/kernel/network_tests

The tests will tell you if your kernel lacks necessary patches or
otherwise cannot support Android userspace networking code. The
failures will be much clearer than the CTS test failures.
