From: Andreas Schwab <schwab@suse.de>
Subject: Re: [patch 4/5] s2io driver updates
Date: Sun, 13 May 2007 15:22:13 +0200
Message-ID: <jer6pkoo3e.fsf@sykes.suse.de>
References: <Pine.GSO.4.10.10604211918060.16549-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, alicia.pena@neterion.com
To: Ananda Raju <Ananda.Raju@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53850 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760569AbXEMNWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2007 09:22:16 -0400
In-Reply-To: <Pine.GSO.4.10.10604211918060.16549-100000@guinness> (Ananda
	Raju's message of "Fri\, 21 Apr 2006 19\:20\:22 -0400 \(EDT\)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju <Ananda.Raju@neterion.com> writes:

> @@ -2704,6 +2792,10 @@ static void tx_intr_handler(fifo_info_t=20
>  		if (txdlp->Control_1 & TXD_T_CODE) {
>  			unsigned long long err;
>  			err =3D txdlp->Control_1 & TXD_T_CODE;
> +			if (err & 0x1) {

This is never true.

> @@ -5743,6 +6246,11 @@ static int rx_osm_handler(ring_info_t *r
>  	skb->dev =3D dev;
> =20
>  	if (err) {
> +		/* Check for parity error */
> +		if (err & 0x1) {

Likewise.

(This is a very old patch, but the issue is still present.)

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
