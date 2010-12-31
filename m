From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 01/15]arch:m68k:ifpsp060:src:fpsp.S Typo change diable to disable.
Date: Fri, 31 Dec 2010 11:33:49 +0100
Message-ID: <AANLkTins7rj1o4rEcEFmVSA2=1yXZSfLdO000gqQP7cg@mail.gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: trivial@kernel.org, linux-m68k@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-media@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 31, 2010 at 00:07, Justin P. Mattock
<justinmattock@gmail.com> wrote:
> The below patch fixes a typo "diable" to "disable". Please let me kno=
w if this
> is correct or not.
>
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

> ---
> =C2=A0arch/m68k/ifpsp060/src/fpsp.S | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/arch/m68k/ifpsp060/src/fpsp.S b/arch/m68k/ifpsp060/src/f=
psp.S
> index 73613b5..26e85e2 100644
> --- a/arch/m68k/ifpsp060/src/fpsp.S
> +++ b/arch/m68k/ifpsp060/src/fpsp.S
> @@ -3881,7 +3881,7 @@ _fpsp_fline:
> =C2=A0# FP Unimplemented Instruction stack frame and jump to that ent=
ry
> =C2=A0# point.
> =C2=A0#
> -# but, if the FPU is disabled, then we need to jump to the FPU diabl=
ed
> +# but, if the FPU is disabled, then we need to jump to the FPU disab=
led
> =C2=A0# entry point.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0movc =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0%pcr,%d0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0btst =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0&0x1,%d0

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
