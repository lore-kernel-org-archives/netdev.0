From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 08/10] tty_io: export tty_class
Date: Mon, 1 Jun 2009 19:10:11 +0400
Message-ID: <bc64b4640906010810l8ace77byfbd650b549f9b5c3@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
	 <1243868091-5315-9-git-send-email-dbaryshkov@gmail.com>
	 <20090601160721.7b262469@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:56015 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbZFAPKL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 11:10:11 -0400
In-Reply-To: <20090601160721.7b262469@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/1 Alan Cox <alan@lxorguk.ukuu.org.uk>:
> On Mon, =A01 Jun 2009 18:54:49 +0400
> Dmitry Eremin-Solenikov <dbaryshkov@gmail.com> wrote:
>
>> Currently tty_class in a public variable in the tty_io.c
>> Export it to the modules to allow some usefull tricks.
>
> Thats exactly why it isn't exported. We don't want "tricks".

I'd like to find a struct device corresponding to the struct tty_struct
from the ldisc .open call. What would be the best way for me to do this=
?
I used class_find_device finding the device with matching minor. Will i=
t be
acceptable, if I just move this code into tty_* file and export it as
to modules?


--=20
With best wishes
Dmitry
