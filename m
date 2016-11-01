From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v2] rtl8xxxu: Fix for agressive power saving by rtl8723bu
 wireless IC
Date: Tue, 1 Nov 2016 08:31:58 +0100
Message-ID: <CACna6rx3yxkM8g7_cbuRg_LgH5BNN=cJKHsJ+gKD6+hX57_8-Q@mail.gmail.com>
References: <20161101072447.GA21575@cube>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: John Heenan <john@zgus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36008 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034678AbcKAHb7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 03:31:59 -0400
In-Reply-To: <20161101072447.GA21575@cube>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 08:24, John Heenan <john@zgus.com> wrote:
> @@ -5779,6 +5779,12 @@ static int rtl8xxxu_start(struct ieee80211_hw *hw)
>
>         ret =3D 0;
>
> +       if(priv->fops =3D=3D &rtl8723bu_fops) {

OK, let me be the first. Documentation/CodingStyle also says to use
space between "if" and "(" ;)


> @@ -6080,9 +6086,11 @@ static int rtl8xxxu_probe(struct usb_interface *in=
terface,
>                 goto exit;
>         }
>
> -       ret =3D rtl8xxxu_init_device(hw);
> -       if (ret)
> -               goto exit;
> +       if(priv->fops !=3D &rtl8723bu_fops) {

Same here.

I reviewed style only.

--=20
Rafa=C5=82
