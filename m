From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 12:43:40 +0100
Message-ID: <CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Thu, Dec 26, 2013 at 10:37 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Changes in version 3:

> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rcar_can_regs';
> - removed unneeded type cast in the probe() method.

> +/* Mailbox registers structure */
> +struct rcar_can_mbox_regs {
> +       u32 id;         /* IDE and RTR bits, SID and EID */
> +       u8 stub;        /* Not used */
> +       u8 dlc;         /* Data Length Code - bits [0..3] */
> +       u8 data[8];     /* Data Bytes */
> +       u8 tsh;         /* Time Stamp Higher Byte */
> +       u8 tsl;         /* Time Stamp Lower Byte */
> +} __packed;

Sorry, I missed the earlier discussion, but why the _packed?
One u32 and 12 bytes makes a nice multiple of 4.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
