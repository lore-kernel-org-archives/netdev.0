From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 1/6] X25: Use identifiers for X25 to device interface
Date: Mon, 19 Apr 2010 09:51:01 +1000
Message-ID: <h2td45a3acc1004181651xd70115dr5671210761035838@mail.gmail.com>
References: <1271584310.6280.425.camel@ibex> <4BCAE509.9000209@Calva.COM>
	 <4BCAE84A.2030701@Calva.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: John Hughes <john@calva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f199.google.com ([209.85.223.199]:62671 "EHLO
	mail-iw0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab0DRXvE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 19:51:04 -0400
Received: by iwn37 with SMTP id 37so49881iwn.15
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 16:51:01 -0700 (PDT)
In-Reply-To: <4BCAE84A.2030701@Calva.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

Thanks, missed that, ill see if any of the driver areas have comments
and make a V2 patch with explicit values.

Your right, it would be nice if xotd/xoe could pickup the same
definition from user space.
include/net/x25device.h is not intended as a user space header.
include/linux/net/x25.h is the user space header for the x25 socket
layer interface, so I don't think these definitions should go there.

I think the right way to do it is add a new userspace header
include/linux/if_x25.h then include that from net/x25_device.h?

Regards,
Andrew.


On Sun, Apr 18, 2010 at 9:08 PM, John Hughes <john@calva.com> wrote:
> John Hughes wrote:
>>
>> Shouldn't you use explicit values here?
>>
>> enum {
>> =A0 =A0X25_IFACE_DATA =3D 0x00, /* explicit value for ABI stability =
*/
>> =A0 =A0...
>
> Oh, and is net/x25device.h suitable for inclusion from user space (xo=
td for
> example)?
>
>
