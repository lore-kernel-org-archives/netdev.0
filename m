From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v2 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
Date: Tue, 27 Sep 2016 11:25:16 +0900
Message-ID: <CAAedzxpof8zBLL5AvKQLZVMoof63fAsds+7bTL9hNAdQgEbE8Q@mail.gmail.com>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
 <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
 <1474797596-13320-3-git-send-email-zenczykowski@gmail.com>
 <CAKD1Yr2MHqFMmJyf89pWzopcr07ziVcHqUB+oNWdphKx95nGDg@mail.gmail.com> <CANP3RGdqvWsRRW=UFnC=z+1QDSajsfmswjs+BZB8jB+1NkGiqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Lorenzo Colitti <lorenzo@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35452 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753492AbcI0CZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 22:25:38 -0400
Received: by mail-lf0-f43.google.com with SMTP id l131so757974lfl.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 19:25:37 -0700 (PDT)
In-Reply-To: <CANP3RGdqvWsRRW=UFnC=z+1QDSajsfmswjs+BZB8jB+1NkGiqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 September 2016 at 11:23, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
>> Given that some of this patch checks for =3D=3D -1, and some of it check=
s
>> for !=3D 0... is it possible that setting the value to something
>> unexpected like -3 will cause any issues to the stack? (Other than
>> just rendering IPv6 unusable on this interface, which seems like a
>> given.)
>
> You shouldn't be able to set it to -3, that's what the extra1 is for...

the proc_dointvec_minmax reference with &minus_one means you shouldn't
be able to set it below -1.
