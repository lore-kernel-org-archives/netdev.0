From: Olof Johansson <olof@lixom.net>
Subject: Re: netlabel build warning...
Date: Sat, 9 Aug 2014 09:19:02 -0700
Message-ID: <CAOesGMgCDd9+=x9M=sP+rRgJOKrT+SC7VNw_X_mj5WZtiPxW1g@mail.gmail.com>
References: <20140806.145508.377690541948141573.davem@davemloft.net>
	<CAHC9VhTRWhx=qB5XO7f2TmY0-gqR5kWa0d_X8EY9k42tQRVymQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:36984 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaHIQTC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 12:19:02 -0400
Received: by mail-oa0-f46.google.com with SMTP id m1so4936803oag.5
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2014 09:19:02 -0700 (PDT)
In-Reply-To: <CAHC9VhTRWhx=qB5XO7f2TmY0-gqR5kWa0d_X8EY9k42tQRVymQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 4:23 PM, Paul Moore <paul@paul-moore.com> wrote:
> On Wed, Aug 6, 2014 at 5:55 PM, David Miller <davem@davemloft.net> wr=
ote:
>>
>> Please add inline to the nop versions of these helpers, thanks:
>>
>> include/net/netlabel.h:527:12: warning: =E2=80=98netlbl_catmap_setlo=
ng=E2=80=99 defined but not used [-Wunused-function]
>> include/net/netlabel.h:527:12: warning: =E2=80=98netlbl_catmap_setlo=
ng=E2=80=99 defined but not used [-Wunused-function]
>
> I posted a fix to the SELinux list yesterday (link below); in
> retrospect, I should have CC'd netdev, my apologies.  As soon as -rc1
> is released and linux-next opens for business I'll be pushing the
> patch to the SELinux #next branch.
>
>  * http://marc.info/?l=3Dselinux&m=3D140726989229890&w=3D2

Why hold it off for 3.18? It's small and trivial and removes a
warning, might as well go in sooner.


-Olof
