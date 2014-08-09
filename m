From: Paul Moore <paul@paul-moore.com>
Subject: Re: netlabel build warning...
Date: Sat, 09 Aug 2014 12:23:18 -0400
Message-ID: <efdc8ee2-f7ea-4601-9118-88595281bc5d@email.android.com>
References: <20140806.145508.377690541948141573.davem@davemloft.net> <CAHC9VhTRWhx=qB5XO7f2TmY0-gqR5kWa0d_X8EY9k42tQRVymQ@mail.gmail.com> <CAOesGMgCDd9+=x9M=sP+rRgJOKrT+SC7VNw_X_mj5WZtiPxW1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:64916 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaHIQ26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 12:28:58 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so7143448qgd.19
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2014 09:28:57 -0700 (PDT)
In-Reply-To: <CAOesGMgCDd9+=x9M=sP+rRgJOKrT+SC7VNw_X_mj5WZtiPxW1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On August 9, 2014 12:19:02 PM EDT, Olof Johansson <olof@lixom.net> wrot=
e:
>On Wed, Aug 6, 2014 at 4:23 PM, Paul Moore <paul@paul-moore.com> wrote=
:
>> On Wed, Aug 6, 2014 at 5:55 PM, David Miller <davem@davemloft.net>
>wrote:
>>>
>>> Please add inline to the nop versions of these helpers, thanks:
>>>
>>> include/net/netlabel.h:527:12: warning: =E2=80=98netlbl_catmap_setl=
ong=E2=80=99
>defined but not used [-Wunused-function]
>>> include/net/netlabel.h:527:12: warning: =E2=80=98netlbl_catmap_setl=
ong=E2=80=99
>defined but not used [-Wunused-function]
>>
>> I posted a fix to the SELinux list yesterday (link below); in
>> retrospect, I should have CC'd netdev, my apologies.  As soon as -rc=
1
>> is released and linux-next opens for business I'll be pushing the
>> patch to the SELinux #next branch.
>>
>>  * http://marc.info/?l=3Dselinux&m=3D140726989229890&w=3D2
>
>Why hold it off for 3.18? It's small and trivial and removes a
>warning, might as well go in sooner.
>
>
>-Olof

I sent a pull request to Linus yesterday and CC'd netdev.
--=20
paul moore
www.paul-moore.com=20
