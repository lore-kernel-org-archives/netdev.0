From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take21 2/4] kevent: poll/select() notifications.
Date: Sat, 28 Oct 2006 12:04:10 +0200
Message-ID: <45432B1A.8020503@cosmosbay.com>
References: <11619654012104@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:34742 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S1752041AbWJ1KEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2006 06:04:10 -0400
In-reply-to: <11619654012104@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a =E9crit :

> +	file =3D fget(k->event.id.raw[0]);
> +	if (!file)
> +		return -ENODEV;

Please, do us a favor, and use EBADF instead of ENODEV.

EBADF : /* Bad file number */

ENODEV : /* No such device */

You have many ENODEV uses in your patches and that really hurts.

Eric

