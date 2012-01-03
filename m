From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Check if PHY is in operational mode
 before software reset
Date: Wed, 4 Jan 2012 00:30:23 +0100
Message-ID: <CAAwP0s1Uc28VbNnM=0prgzgMUF1dBBbx88D_kG7BRympSU41qA@mail.gmail.com>
References: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
 <1325524131-14585-2-git-send-email-martinez.javier@gmail.com> <20120103.134647.1029494174636172958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@smsc.com, ben@decadent.org.uk,
	eballetbo@iseebcn.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:65532 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab2ACXao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 18:30:44 -0500
Received: by ghbg21 with SMTP id g21so3730027ghb.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 15:30:44 -0800 (PST)
In-Reply-To: <20120103.134647.1029494174636172958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 7:46 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Javier Martinez Canillas <martinez.javier@gmail.com>
> Date: Mon, =C2=A02 Jan 2012 18:08:51 +0100
>
>> + =C2=A0 =C2=A0 /* If energy is detected the PHY is already awake so=
 is not necessary
>> + =C2=A0 =C2=A0 =C2=A0* to disable the energy detect power-down mode=
=2E */
> =C2=A0...
>> + =C2=A0 =C2=A0 /* LAN9210/LAN9211/LAN9220/LAN9221 chips have an int=
ernal PHY that
>> + =C2=A0 =C2=A0 =C2=A0* are initialized in a Energy Detect Power-Dow=
n mode that prevents
>> + =C2=A0 =C2=A0 =C2=A0* the MAC chip to be software reseted. So we h=
ave to wakeup the PHY
>> + =C2=A0 =C2=A0 =C2=A0* before */
>
> Format these comments correctly:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Like this.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * See?
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Not like this.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Ok? */
>

Ok, will resend with the right style.

Besides these coding style issues, does the patch looks good to you?

Best regards,

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain
