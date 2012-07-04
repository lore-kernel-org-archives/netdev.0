From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] net: add support for NS8390 based eth controllers
 on some ColdFire CPU boards
Date: Wed, 04 Jul 2012 07:52:35 -0700
Message-ID: <1341413555.3627.33.camel@joe2Laptop>
References: <1341377789-12970-1-git-send-email-gerg@snapgear.com>
	 <1341377789-12970-3-git-send-email-gerg@snapgear.com>
	 <1341379091.3627.15.camel@joe2Laptop> <4FF3E031.5040703@snapgear.com>
	 <1341383999.3627.20.camel@joe2Laptop>
	 <CAMuHMdVYiQyurOQOoeLbd6zXnaVK8Y9bUC=wXkHxhQO+cQwecQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Ungerer <gerg@snapgear.com>, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVYiQyurOQOoeLbd6zXnaVK8Y9bUC=wXkHxhQO+cQwecQ@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-07-04 at 09:52 +0200, Geert Uytterhoeven wrote:
> On Wed, Jul 4, 2012 at 8:39 AM, Joe Perches <joe@perches.com> wrote:
> >> >> +static int mcf8390_init(struct net_device *dev)
> >> >> +{
> >> >> +  static u32 offsets[] = {
> >> >> +          0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
> >> >> +          0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
> >> >> +  };
> >> >
> >> > const?  u8?
> >>
> >> That is assigned to the "reg_offset" field of "struct ei_device"
> >> (defined in the existing 8390.h) and that is:
> >>
> >>      u32 *reg_offset;         /* Register mapping table */
> >>
> >> So I can't change this.
> >
> > Sure you can, you can assign a u8 to a u32 just fine.
> 
> It's not the value that's assigned, but a pointer to the table, so
> for now it must be non-const u32 *.

Oh, then of course you and Greg are correct.

It looks like the code in ax88796.c may actually
need u32 sizes too.
