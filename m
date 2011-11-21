From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [patch] caif: fix endian conversion in cffrml_transmit()
Date: Mon, 21 Nov 2011 15:36:02 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB0A91AF2@EXDCVYMBSTM005.EQ1STM.local>
References: <20111121061722.GD7354@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:42077 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751044Ab1KUOgT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 09:36:19 -0500
In-Reply-To: <20111121061722.GD7354@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,
=20
> The "tmp" variable here is used to store the result of cpu_to_le16()
> so it should be a u16 instead of an int.  We want the high bits set
> and the current code works on little endian systems but not on big
> endian systems.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks OK by me, unless you want to make sparse with __CHECK_ENDIAN__=20
shut up, then you should use __le16 ;-)

Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Regards,
Sjur
