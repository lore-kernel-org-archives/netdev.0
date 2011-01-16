From: Chin Shi Hong <cshong87@gmail.com>
Subject: Re: Creating virtual interface using C++
Date: Sun, 16 Jan 2011 23:26:14 +0800
Message-ID: <AANLkTimuMO-8XcdaPXMTVDtzdgk_2-jyVndx_znK6398@mail.gmail.com>
References: <AANLkTikcHuHGD4eEmuZr4+p9MSLbySmQwsr_Dj==AZ-y@mail.gmail.com>
	<201101161643.15508.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46240 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab1APP0R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 10:26:17 -0500
Received: by eye27 with SMTP id 27so2167893eye.19
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 07:26:16 -0800 (PST)
In-Reply-To: <201101161643.15508.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/16 R=E9mi Denis-Courmont <remi@remlab.net>:
> =A0 =A0 =A0 =A0Hello,
>
> Le dimanche 16 janvier 2011 16:37:05 Chin Shi Hong, vous avez =E9crit=
 :
>> Can someone give me suggestion for C++ codes that will create a
>> virtual network interface
>
> It depends what you mean by virtual. Normally, you should use /dev/ne=
t/tun
> which is documented at linux-2.6/Documentation/networking/tuntap.txt
>
>> for the existing network interface
>> (including wired and wireless network interface)?
>
> But that part of your question does not make any sense.
>
> --
> R=E9mi Denis-Courmont
> http://www.remlab.net/
> http://fi.linkedin.com/in/remidenis
>

Don't know how to explain by virtual. But, you know the "iw" utility
(http://wireless.kernel.org/en/users/Documentation/iw)? If you
installed this utility, and then run the command "sudo iw dev
<wireless interface> interface add <virtual interface name> type
<wireless mode>", for example "sudo iw dev wlan0 interface add mon0
type monitor", it will add an virtual wireless interface named "mon0"
for the wireless interface "wlan0", then switch it to monitor mode. if
you run that command, you will know what I mean.
