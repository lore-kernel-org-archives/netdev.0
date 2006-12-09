From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Sat, 9 Dec 2006 14:05:06 +0100
Message-ID: <a32f33a40612090505j23251626k891edae1c06b6fb2@mail.gmail.com>
References: <200612031919.05228.IvDoorn@gmail.com>
	 <200612031339.28148.flamingice@sourmilk.net>
	 <200612081956.14158.IvDoorn@gmail.com>
	 <200612082100.14592.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:49082 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050AbWLINFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 08:05:08 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1416241nfa
        for <netdev@vger.kernel.org>; Sat, 09 Dec 2006 05:05:07 -0800 (PST)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200612082100.14592.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

> > I have checked the adm80211 code as well, it seems to behave quite the
> > same, with the most notable difference the fact that adm80211 writes the
> > READ_OPCODE and the word index within a single command, while in
> > eeprom_93cx6 this is split into 2 seperate write commands.
> > I have not yet tested the exact impact for rt2x00 devices when they would
> > combine the write commands, but if that has no impact (or the adm80211
> > suffers no impact when the write commands are being split) then rt2x00 and
> > adm80211 could indeed share the eeprom_93cx6 module.
> Hm, which way is the correct way? (is there a correct way?)

I have tested rt2x00 with combining the read command and word index writing,
and it is working perfectly.

> > If eeprom_93cx6 is moved to the /lib folder of the kernel, should it be
> > approved by a different maintainer first?
> >
> I don't think so, but I'm not sure. BTW, I think there can actually be
> another
> user of this code. Take a look at drivers/scsi/aic7xxx/aic7xxx_93cx6.c
>
> I'm not sure who the maintainer for this is. Should be okay to just have
> adm8211 and rt2x00 using eeprom_93cx6 for now, unless you have a spare
> aic7xxx supported device lying around. ;)

Nope, don't have that device. I'll create a patch that will place the eeprom
module in the /lib folder. I'll send that to the list as soon as possible.

Ivo
