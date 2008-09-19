From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 08/14] Phonet: receive path socket lookup
Date: Fri, 19 Sep 2008 09:20:26 +0300
Message-ID: <200809190920.26906.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-8-git-send-email-remi.denis-courmont@nokia.com> <20080916165205.GK8702@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:61780 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbYISGVl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 02:21:41 -0400
In-Reply-To: <20080916165205.GK8702@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 September 2008 19:52:05 ext Arnaldo Carvalho de Melo, you=
 wrote:
> > +	/* Push data to the socket (or other sockets connected to it). */
> > +	err =3D pn_sk(sk)->handler(sk, skb);
>
> wouldn't be nice to use sk_backlog_rcv() and sk_receive_skb()?

Yes, thanks. I had missed sk_receive_skb(), in which case, sk_backlog_r=
cv()=20
does not work so well.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
