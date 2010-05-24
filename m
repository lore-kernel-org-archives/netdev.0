From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [patch v2] caif: cleanup: remove duplicate checks
Date: Mon, 24 May 2010 22:47:41 +0200
Message-ID: <AANLkTilHv7m-oJSlXHJRLT9BLKscGLSFnGVCOB9U0kic@mail.gmail.com>
References: <20100522204519.GW22515@bicker> <4BF8E6FE.9000303@bfs.de>
	 <20100524162815.GA22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: walter harms <wharms@bfs.de>, netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62610 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756198Ab0EXUyD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 16:54:03 -0400
In-Reply-To: <20100524162815.GA22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Dan Carpenter <error27@gmail.com> wrote:
> "phyinfo" can never be null here because we assigned it an address, s=
o I
> removed both the assert and the second check inside the if statement.=
 =C2=A0I
> removed the "phyinfo->phy_layer !=3D NULL" check as well because that=
 was
> asserted earlier.
>
> Walter Harms suggested I move the "phyinfo->phy_ref_count++;" outside
> the if condition for readability, so I have done that.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
Thanks, this looks good.
