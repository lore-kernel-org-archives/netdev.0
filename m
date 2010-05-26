From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH 8/17] net/caif: Add missing spin_unlock
Date: Wed, 26 May 2010 20:13:32 +0200
Message-ID: <AANLkTilnCabvmeF11Rx7XlEHxwqrnBk2JLznOBLrCHuC@mail.gmail.com>
References: <Pine.LNX.4.64.1005261756150.23743@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005261756150.23743@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia@diku.dk> wrote:
> From: Julia Lawall <julia@diku.dk>
>
> Add a spin_unlock missing on the error path. =C2=A0The spin lock is u=
sed in a
> balanced way elsewhere in the file.

This bug is already fixed an part of net-2.6 in
"[PATCH net-2.6 5/6] caif: Bugfix - missing spin_unlock".

Regards
Sjur
