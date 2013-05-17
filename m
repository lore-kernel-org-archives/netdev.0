From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: ethernet: sun: initialize variables directly
Date: Fri, 17 May 2013 13:23:13 -0700 (PDT)
Message-ID: <20130517.132313.933656167661213099.davem@davemloft.net>
References: <1368803268-27698-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: emilio@elopez.com.ar
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368803268-27698-1-git-send-email-emilio@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Emilio L=F3pez <emilio@elopez.com.ar>
Date: Fri, 17 May 2013 12:07:45 -0300

> Clean up the code a bit to initialize the variables directly when
> defining them.
>=20
> Signed-off-by: Emilio L=F3pez <emilio@elopez.com.ar>

Poorly styled, should be:

	u16 hash_table[4] =3D { 0 };
