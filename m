From: roel kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] gianfar: Fix tests of unsigneds in gfar_parse_group()
Date: Wed, 16 Dec 2009 16:48:00 +0100
Message-ID: <25e057c00912160748x504cb4c1ibaa3ab6d26864525@mail.gmail.com>
References: <4B27D87D.5070908@gmail.com> <9F4C7D19E8361D4C94921B95BE08B81BA08D5A@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755173AbZLPPsZ@vger.kernel.org>
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA08D5A@zin33exm22.fsl.freescale.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2009 at 6:04 AM, Kumar Gopalpet-B05799
<B05799@freescale.com> wrote:
>
>>Won't it be better to change types of interruptTransmit,
>>-Receive and -Error in =C2=A0struct gfar_priv_grp itself. Something
>>like this:

> struct gfar_priv_grp {
> ....
> - =C2=A0 =C2=A0 =C2=A0 unsigned int interruptTransmit;
> - =C2=A0 =C2=A0 =C2=A0 unsigned int interruptReceive;
> - =C2=A0 =C2=A0 =C2=A0 unsigned int interruptError;
>
> + =C2=A0 =C2=A0 =C2=A0 int interruptTransmit;
> + =C2=A0 =C2=A0 =C2=A0 int interruptReceive;
> + =C2=A0 =C2=A0 =C2=A0 int interruptError;
> ....
> }
>
> --
>
> Thanks
> Sandeep

I don't think that's better. Only the error returned is signed,
If none occurred the irq thereafter is unsigned.

Thanks,

Roel
