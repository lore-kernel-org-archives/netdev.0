From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 09/11] netdev: bfin_mac: only use
	hardware checksum in normal IPv4 mode
Date: Mon, 10 May 2010 11:35:46 -0400
Message-ID: <AANLkTil4XZW9MgGMjrAh2q6Ey28yibvy8q8SUs7-tp-7@mail.gmail.com>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
	<1273400337-26501-9-git-send-email-vapier@gentoo.org> <20100510.044222.233422592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jon.kowal@dspecialists.de,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:56497 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab0EJPgG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 11:36:06 -0400
Received: by gxk9 with SMTP id 9so2831441gxk.8
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 08:36:06 -0700 (PDT)
In-Reply-To: <20100510.044222.233422592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 10, 2010 at 07:42, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> Date: Sun, =C2=A09 May 2010 06:18:55 -0400
>
>> From: Jon Kowal <jon.kowal@dspecialists.de>
>>
>> The Blackfin on-chip MAC checksum logic only works when the IP packe=
t has
>> a header length of 20 bytes. =C2=A0This is true for most IPv4 packet=
s, but not
>> for IPv6 packets or IPv4 packets which use header options. =C2=A0So =
only use
>> the hardware checksum when appropriate.
>>
>> Signed-off-by: Jon Kowal <jon.kowal@dspecialists.de>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>
> In order to make the tree bisectable, combine bug fixes into the chan=
ges
> that add the bugs instead of letting them live in the final tree when
> they don't need to.
>
> You should have just combined this patch into the patch that added th=
e
> FCS inversion stuff.

i dont think that is true.  this bug existed before the FCS inversion
stuff -- notice the csum complete behavior changes.
-mike
