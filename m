From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: [PATCH] e1000: Silence sparse warnings by correcting type
Date: Fri, 23 Mar 2012 16:01:15 +0200
Message-ID: <CAMXE1-phb7_4h2Z-EdJ_QK0EYYcQkFwaMZevFaTNmet6OHF7Dw@mail.gmail.com>
References: <1332233951-31129-1-git-send-email-Andrei.Emeltchenko.news@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:36848 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752775Ab2CWOBR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 10:01:17 -0400
Received: by lahj13 with SMTP id j13so2512663lah.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 07:01:16 -0700 (PDT)
In-Reply-To: <1332233951-31129-1-git-send-email-Andrei.Emeltchenko.news@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping

On Tue, Mar 20, 2012 at 10:59 AM, Andrei Emeltchenko
<Andrei.Emeltchenko.news@gmail.com> wrote:
> From: Andrei Emeltchenko <andrei.emeltchenko@intel.com>
>
> Silence sparse warnings shown below:
> ...
> drivers/net/ethernet/intel/e1000/e1000_main.c:3435:17: warning:
> =A0 =A0 =A0 =A0cast to restricted __le64
> drivers/net/ethernet/intel/e1000/e1000_main.c:3435:17: warning:
> =A0 =A0 =A0 =A0cast to restricted __le64
> ...
>
> Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@intel.com>
> ---
> =A0drivers/net/ethernet/intel/e1000/e1000_main.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/=
net/ethernet/intel/e1000/e1000_main.c
> index 6419a88..1bf73cf 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3377,7 +3377,7 @@ static void e1000_dump(struct e1000_adapter *ad=
apter)
> =A0 =A0 =A0 =A0for (i =3D 0; tx_ring->desc && (i < tx_ring->count); i=
++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct e1000_tx_desc *tx_desc =3D E100=
0_TX_DESC(*tx_ring, i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct e1000_buffer *buffer_info =3D &=
tx_ring->buffer_info[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct my_u { u64 a; u64 b; };
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct my_u { __le64 a; __le64 b; };
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct my_u *u =3D (struct my_u *)tx_d=
esc;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char *type;
>
> @@ -3421,7 +3421,7 @@ rx_ring_summary:
> =A0 =A0 =A0 =A0for (i =3D 0; rx_ring->desc && (i < rx_ring->count); i=
++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct e1000_rx_desc *rx_desc =3D E100=
0_RX_DESC(*rx_ring, i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct e1000_buffer *buffer_info =3D &=
rx_ring->buffer_info[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct my_u { u64 a; u64 b; };
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct my_u { __le64 a; __le64 b; };
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct my_u *u =3D (struct my_u *)rx_d=
esc;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char *type;
>
> --
> 1.7.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
