From: Paul Moore <paul@paul-moore.com>
Subject: Re: netlabel build warning...
Date: Wed, 6 Aug 2014 19:23:39 -0400
Message-ID: <CAHC9VhTRWhx=qB5XO7f2TmY0-gqR5kWa0d_X8EY9k42tQRVymQ@mail.gmail.com>
References: <20140806.145508.377690541948141573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:48520 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbaHFXXk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 19:23:40 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so3384650wgh.9
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 16:23:39 -0700 (PDT)
In-Reply-To: <20140806.145508.377690541948141573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 5:55 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> Please add inline to the nop versions of these helpers, thanks:
>
> include/net/netlabel.h:527:12: warning: =E2=80=98netlbl_catmap_setlon=
g=E2=80=99 defined but not used [-Wunused-function]
> include/net/netlabel.h:527:12: warning: =E2=80=98netlbl_catmap_setlon=
g=E2=80=99 defined but not used [-Wunused-function]

I posted a fix to the SELinux list yesterday (link below); in
retrospect, I should have CC'd netdev, my apologies.  As soon as -rc1
is released and linux-next opens for business I'll be pushing the
patch to the SELinux #next branch.

 * http://marc.info/?l=3Dselinux&m=3D140726989229890&w=3D2

--=20
paul moore
www.paul-moore.com
