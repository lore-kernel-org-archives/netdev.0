From: Timur Tabi <timur.tabi@gmail.com>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Tue, 20 Apr 2010 10:01:48 -0500
Message-ID: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
References: <1271632401-2472-1-git-send-email-afleming@freescale.com>
	<m2ged82fe3e1004191408p53f19073x106ef56677c8a5df@mail.gmail.com>
	<DD217C72-156B-403D-B83B-EB365C782F2B@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36777 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab0DTPCT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 11:02:19 -0400
Received: by pva18 with SMTP id 18so3970917pva.19
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:02:18 -0700 (PDT)
In-Reply-To: <DD217C72-156B-403D-B83B-EB365C782F2B@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 19, 2010 at 11:43 PM, Kumar Gala <galak@kernel.crashing.org=
> wrote:

> spin_event_timeout doesn't make sense for this. =A0The patch is fine.

Can you please elaborate on that?  I don't understand why you think
that.  spin_event_timeout() takes an expression and a timeout, and
loops over the expression calling cpu_relax(), just like this loop
does.

--=20
Timur Tabi
Linux kernel developer at Freescale
