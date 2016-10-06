From: Aaron Conole <aconole@bytheb.org>
Subject: Re: 4.9-rc0: nf_hooks_ingress missing, breaking compilation
Date: Thu, 06 Oct 2016 09:54:15 -0400
Message-ID: <f7ttwcpy454.fsf@redhat.com>
References: <20161006065844.GA27024@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: kernel list <linux-kernel@vger.kernel.org>,
        Netdev list <netdev@vger.kernel.org>, pablo@netfilter.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34459 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbcJFNyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 09:54:20 -0400
Received: by mail-qk0-f180.google.com with SMTP id j129so16439066qkd.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 06:54:19 -0700 (PDT)
In-Reply-To: <20161006065844.GA27024@amd> (Pavel Machek's message of "Thu, 6
        Oct 2016 08:58:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek <pavel@ucw.cz> writes:

> Hi!

Hi Pavel,

> In kernel based on edadd0e, I get plenty of errors such as:

In this case, I screwed up - sincere apologies.

Enabling CONFIG_NETFILTER_INGRESS will work around this error for the
time being, while the fix makes it way through the various trees.

> net/netfilter/core.c:96:3: note: in expansion of macro =E2=80=98rcu_assig=
n_pointer=E2=80=99
>    rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
>    ^
> In file included from ./include/linux/linkage.h:4:0,
>                  from ./include/linux/kernel.h:6,
>                  from net/netfilter/core.c:10:
> net/netfilter/core.c:96:30: error: =E2=80=98struct net_device=E2=80=99 ha=
s no member named =E2=80=98nf_hooks_ingress=E2=80=99
>    rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
>                               ^
>
> Config is attached.
>
> [Ok, I guess testing -rc0 is "a bit too brave" :-)]
>
> Best regards,
> 									Pavel
