From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 16:43:16 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904211642320.31780@qirst.com>
References: <1238701718.5669.26.camel@bender>  <alpine.DEB.1.10.0904211131340.21796@qirst.com>  <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com> <7e0dd21a0904211346p523b1e1fo7f8ec7bd18ad87cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-716562517-1147950496-1240346596=:31780"
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:51942 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbZDUUvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 16:51:14 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4687E82C718
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:01:39 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UF+FMW3AiWht for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 17:01:34 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9D17682C712
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:01:34 -0400 (EDT)
In-Reply-To: <7e0dd21a0904211346p523b1e1fo7f8ec7bd18ad87cf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---716562517-1147950496-1240346596=:31780
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 21 Apr 2009, Johann Baudy wrote:

> >> Could you clean then states up a bit to reflect what they actually mea=
n?
> >>
> >> TP_STATUS_AVAILABLE =A0 =A0 =A0 =A0 =A0 =A0 =3D> Frame is available
> >> TP_STATUS_SEND_REQUEST =A0 =A0 =A0 =A0 =A0=3D> Frame waits for sending
> >> TP_STATUS_SENDING =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D> Frame is being sent=
=2E
> >
> > Ok
>
> Do you suggest to replace previous TP_STATUS_KERNEL with TP_STATUS_AVAILA=
BLE?
> or Add a new status?

Well yes. But I guess you know best what to call them. Just make them
more decriptive of their function.


---716562517-1147950496-1240346596=:31780--
