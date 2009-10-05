From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
	invalid context at mm/slub.c:1719
Date: Mon, 5 Oct 2009 12:08:53 +0800
Message-ID: <a8e1da0910042108h2adad63j46e81f8ef0ff38d4@mail.gmail.com>
References: <4AC59D8A.6000102@hartkopp.net>
	 <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com>
	 <4AC6247E.7050308@hartkopp.net> <20091003070622.GA4110@darkstar>
	 <4AC71CAA.9090704@hartkopp.net>
	 <a8e1da0910032026m66200c08jf9201bbfe34b2f30@mail.gmail.com>
	 <20091004180635.GA11272@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org,
	"Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
To: "Gustavo F. Padovan" <gustavo@padovan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:37716 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbZJEEJa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 00:09:30 -0400
In-Reply-To: <20091004180635.GA11272@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2009 at 2:06 AM, Gustavo F. Padovan <gustavo@padovan.org=
> wrote:
>
> Hi all,
>
> * Dave Young <hidave.darkstar@gmail.com> [2009-10-04 11:26:17 +0800]:
>
>>
>> I can reproduce the bug.
>>
>> It's probably caused by the l2cap changes by =C2=A0Gustavo F. Padova=
n
>> <gustavo@las.ic.unicamp.br>, I didn't see such problem after reverti=
ng
>> Gustavo's patch series.
>
> I can't reproduce the bug. I'm trying to reproduce it to figure out w=
hat of
> my changes cause it.
>
> I' running
>
> $ dund -snu -i 00:11:67:CD:0F:CB # to pretend to be dialup/telephone
>
> and on the other side
>
> $ rfcomm bind 0 00:11:67:CD:0F:CB 1
> $ wvdial =C2=A0# wvdial to /dev/rfcomm0
>
> Both sides are on the same machine. Do you see any real difference
> between my try and the call that get the bug?

Just try connecting to a mobile phone with bluetooth on, then set rfcom=
m.conf

I did:
rfcomm connect 0;
after connection ok, press ctrl+C to hangup

>
>
> --
> Gustavo F. Padovan
>



--=20
Regards
dave
