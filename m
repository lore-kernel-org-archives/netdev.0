From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] Use dev_port for the ID of a network device.
Date: Tue, 1 Jul 2014 09:25:47 -0300
Message-ID: <20140701122547.GA1204@oc0268524204.ibm.com>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <87egy54lwb.fsf@nemi.mork.no>
 <87a98t4jcm.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:39424 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbaGAMZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 08:25:57 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 1 Jul 2014 09:25:55 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id E8900352006A
	for <netdev@vger.kernel.org>; Tue,  1 Jul 2014 08:25:47 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s61CQ7m34284542
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 09:26:08 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s61CPqgr027521
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 08:25:52 -0400
Content-Disposition: inline
In-Reply-To: <87a98t4jcm.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2014 at 09:40:57AM +0200, Bj=F8rn Mork wrote:
> FYI: I just got this back from systemd-devel-owner@lists.freedesktop.=
org :
>=20
>  Please subscribe to this mailing list, all non-subscriber emails are
>  automatically rejected by the server.
> =20
>  If you actually don't want to receive the mails, stay subscribed but
>  just disable the delivery in the mailman web interface. You will sti=
ll
>  be able to send messages that way.
> =20
>  We were unable to cope with the amount of SPAM, and the moderation
>  queue was not actually moderated by anybody, so rejection seemed mor=
e
>  appropriate than no answer and no delivery to the list.
> =20
>  Thanks for understanding.
>=20
>=20
> Please do not crosspost between netdev and closed mailing lists.  It
> splits the followup threads between those who are inside the closed
> community and those who are not.
>=20
> I've removed systemd-devel from the CC list of this email.
>=20
> Thanks for understanding.
>=20
>=20
> Bj=F8rn
>=20

Not sure how, but my patch got through, and I don't recall being
subscribed, so I thought it was a an open list. Anyway, it's something
that I considered important to be considered by the two communities.

Kay raises up the matter of still using dev_id. Since we had drivers
that used that in the past, should we use it as a fallback for older
kernels where dev_port is not there?

Regards.
Cascardo.
