From: f8arr <f8arr@f8arr.org>
Subject: Re: [AX25] kernel panic
Date: Sun, 20 Sep 2009 11:09:31 +0200
Message-ID: <4AB5F14B.4030807@f8arr.org>
References: <4AA82BF0.7040203@upmc.fr> <20090910142436.GB10547@linux-mips.org> <4AA9288B.2070205@upmc.fr> <20090911120557.GA12175@linux-mips.org> <4AB5EAE5.6070605@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srvradiohertz.montaigne.u-bordeaux.fr ([147.210.91.241]:33527
	"EHLO f5kbw.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751254AbZITJJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 05:09:34 -0400
Received: from [192.168.0.2] ([82.236.133.114]:37094)
	by f5kbw.org ([147.210.91.241]:25) with [XMail 1.21 ESMTP Server]
	id <SA3C21> for <netdev@vger.kernel.org> from <f8arr@f8arr.org>;
	Sun, 20 Sep 2009 11:57:38 +0200
In-Reply-To: <4AB5EAE5.6070605@upmc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi Bernard,

My problem wasn't exactly the same has your.
But !

Doing a boot with the kernel option "nosmp" wasn't suffisant... it=20
seemed to load the smp and then, while reading the boot option,=20
unsetting them... but it was too late. (I saw that looking the dmesg).

My solution has been to compile a kernel without smp to be sure that=20
nothing goes up... and it worked !

Regards
f8arr

Bernard Pidoux a =E9crit :
> Hi,
>
> Here are the first events noticed since I turned on=20
> CONFIG_DEBUG_OBJECTS_TIMERS option.
>
> First a kernel BUG, second a kernel panic.
>
> Best regards,
>
> Bernard Pidoux
>
>
>
>
>
