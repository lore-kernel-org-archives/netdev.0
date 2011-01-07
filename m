From: Chin Shi Hong <cshong87@gmail.com>
Subject: Re: Use ioctl() to list all network interfaces.
Date: Fri, 7 Jan 2011 13:41:31 +0800
Message-ID: <AANLkTik8vvY4Qk3iX+CFcDrUV6Dki2MA2tU5ji9R_uqW@mail.gmail.com>
References: <AANLkTi=Xb4TuKcCd-DgN5ZnYzRHV1RjDScyjRkqyb4P+@mail.gmail.com>
	<4f9hv7-kev.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61709 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab1AGFld convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 00:41:33 -0500
Received: by eye27 with SMTP id 27so7523718eye.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 21:41:31 -0800 (PST)
In-Reply-To: <4f9hv7-kev.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 7, 2011 at 1:07 AM, Alexander Clouter <alex@digriz.org.uk> =
wrote:
> Chin Shi Hong <cshong87@gmail.com> wrote:
>>
>> The following codes are just part of my application's source codes:
>>
>> --begin of some codes--
>> ifconf ifc;
>> ret =3D ioctl(n, SIOCGIFCONF,&ifc);
>> --End of some codes--
>>
>> My application's role is to display all network interfaces, includin=
g
>> the network interface which are down.
>>
>> However, with the above codes, my application only display the netwo=
rk
>> interface which are already up. The network interface which are down
>> will not be displayed.
>>
>> So, what can I do to make my application display all network
>> interfaces, including the network interface which are down?
>>
> getifaddrs(), you get the IPv6 ones too this way.
>
> Cheers
>
> --
> Alexander Clouter
> .sigmonster says: I've only got 12 cards.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

getifaddrs() helpful also. Thank you!

Regards,
