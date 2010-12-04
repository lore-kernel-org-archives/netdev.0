From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] vsprintf: Add %pMbt, bluetooth mac address
Date: Sat, 4 Dec 2010 12:03:50 +0100
Message-ID: <AANLkTi=qh0GKp3BdKO9GX1qmM3iJ6J_F3fLqZ8qNAw5v@mail.gmail.com>
References: <cover.1291419007.git.joe@perches.com>
	<a33a0b00eeb29713a08d91156cbb2d816176f990.1291419007.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:56439 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab0LDLDv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 06:03:51 -0500
In-Reply-To: <a33a0b00eeb29713a08d91156cbb2d816176f990.1291419007.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/4 Joe Perches <joe@perches.com>:
> Bluetooth output the MAC address in reverse order.
> Bluetooth memory order: 00 01 02 03 04 05 is output "05:04:03:02:01:0=
0".
>
> This can save overall text when bluetooth is compiled in.
>
> Bluetooth currently uses a very slightly unsafe local function (batos=
tr)
> to output these formatted addresses.
>
> Adding %pMbt allows the batostr function to be removed.

Just a nitpick:
You could call it %pMR, as in 'Reverse', so it sounds better when/if
some other subsystem uses it. It would also be a hint of what is this
doing instead of where it came from.

Best Regards,
Micha=B3 Miros=B3aw
