From: huajun li <huajun.li.lee@gmail.com>
Subject: Re: [PATCHv2 net-next-2.6] rndis_host: Poll status before control
 channel where necessary
Date: Wed, 13 Apr 2011 14:04:12 +0800
Message-ID: <BANLkTikACtpScQWr6ec5i1O+BBLEek2+7w@mail.gmail.com>
References: <1302670523.5282.610.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mark Glassberg <vzeeaxwl@myfairpoint.net>,
	linux-usb@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39755 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab1DMGEO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 02:04:14 -0400
In-Reply-To: <1302670523.5282.610.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> +static const struct driver_info =A0 =A0 =A0 =A0rndis_poll_status_inf=
o =3D {
> + =A0 =A0 =A0 .description =3D =A0"RNDIS device (poll status before c=
ontrol)",
> + =A0 =A0 =A0 .flags =3D =A0 =A0 =A0 =A0FLAG_ETHER | FLAG_FRAMING_RN =
| FLAG_NO_SETINT,

Hi,
   How about add  FLAG_POINTTOPOINT  to flags if the device has no
globally assigned MAC?  This new added mask code could make device
interface naming consistent.

Thanks,
--Huajun
