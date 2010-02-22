From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 5/5] temac: add missing mask
Date: Mon, 22 Feb 2010 15:25:32 -0700
Message-ID: <fa686aa41002221425p357d7806n85e15f713d1034ec@mail.gmail.com>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
	<1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch> <1266865621-28955-3-git-send-email-gfilip@ee.ethz.ch>
	<1266865621-28955-4-git-send-email-gfilip@ee.ethz.ch> <1266865621-28955-5-git-send-email-gfilip@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: gfilip@ee.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:50906 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab0BVWZx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 17:25:53 -0500
Received: by gxk9 with SMTP id 9so3642220gxk.8
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 14:25:52 -0800 (PST)
In-Reply-To: <1266865621-28955-5-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2010 at 12:07 PM,  <gfilip@ee.ethz.ch> wrote:
> For Virtex4-FX this mask is necessary. I think this is also true for =
Virtex5. Please test.
>
> Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
> ---
> =A0drivers/net/ll_temac_main.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.=
c
> index 8b4e1b9..43d51b7 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -627,7 +627,7 @@ static void ll_temac_recv(struct net_device *ndev=
)
> =A0 =A0 =A0 =A0while ((bdstat & STS_CTRL_APP0_CMPLT)) {
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D lp->rx_skb[lp->rx_bd_ci];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 length =3D cur_p->app4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 length =3D (cur_p->app4 & 0x3fff);

A patch making this change has already been merged into david's next tr=
ee.

g.
