From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] drivers: atm: checkpatch.pl fixed coding style
 issues in eni.c
Date: Sun, 20 Jan 2013 23:04:28 -0500 (EST)
Message-ID: <20130120.230428.1678269076372823495.davem@davemloft.net>
References: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
	<1358723575-8345-5-git-send-email-patrik.karlin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: patrik.karlin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358723575-8345-5-git-send-email-patrik.karlin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Patrik Karlin <patrik.karlin@gmail.com>
Date: Mon, 21 Jan 2013 00:12:55 +0100

> This patch fixes statement placement around if/else/for statments
> as suggested by checkpatch.pl
>=20
> Signed-off-by: Patrik K=E5rlin <patrik.karlin@gmail.com>

This patch set is a good example of why nobody should
fix up coding style in such a robotic way in response
to codingstyle.pl complaints.

> -		    ATM_MAX_AAL5_PDU) eff =3D (length+3) >> 2;
> +		    ATM_MAX_AAL5_PDU)=20

I bet you didn't even notice that in this change you are adding
trailing whitespace, the exact problem you fixed up for this file in a
previous patch of the series.

I really would encourage you to work on something else entirely.

Thanks.
