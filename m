From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Mon, 18 Sep 2017 20:04:00 +0200
Message-ID: <1672561.42E2OEMgHK@natalenko.name>
References: <10035198.1vE6NFrMDO@natalenko.name> <40697505.YK5nrFG7Le@natalenko.name> <CAK6E8=djbT-35JuHq+hhOKOG+BEO3RCwgsVPoKcDhNBph5OezA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:40190 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753513AbdIRSEC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 14:04:02 -0400
In-Reply-To: <CAK6E8=djbT-35JuHq+hhOKOG+BEO3RCwgsVPoKcDhNBph5OezA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On pond=C4=9Bl=C3=AD 18. z=C3=A1=C5=99=C3=AD 2017 20:01:42 CEST Yuchung Che=
ng wrote:
> Yes since it is disabled in the upstream by default. Although you can
> experiment FACK enabled additionally.

OK.

> Do we know the crash you first experienced is tied to this issue?

No, unfortunately. I wasn't able to re-create it again, so lets focus on=20
tcp_fastretrans_alert warning only.
