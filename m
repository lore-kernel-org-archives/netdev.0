From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Wed, 15 Feb 2012 19:16:18 +0100
Message-ID: <1329329778.2469.0.camel@edumazet-laptop>
References: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
	 <1329287109.2555.44.camel@edumazet-laptop>
	 <CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
	 <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAFJW8X_zvqVP+ZZO1BOFHa0XeywnieszMoSub_VKMhoy55J4Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53763 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab2BOSQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 13:16:32 -0500
Received: by werb13 with SMTP id b13so807024wer.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 10:16:31 -0800 (PST)
In-Reply-To: <CAFJW8X_zvqVP+ZZO1BOFHa0XeywnieszMoSub_VKMhoy55J4Og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 18:36 +0100, Piergiorgio Beruto=
 a =C3=A9crit :
> Ok, I take the recvmsg( ... MSG_PEEK|MSG_TRUNC) *USUALLY* returns the
> size of the next packet (which would solve my problem without any ugl=
y
> & deprecated ioctl) when passing a "too small buffer" but as you said
> AF_UNIX sockets do not implement this behavior...
>=20
> Are you proposing to implement such patch in the kernel to fix this?
> Do you want me to test it?
>=20

Yes please test it and I'll submit it.

Thanks
