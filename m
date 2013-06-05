From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 7/8] sh_eth: consolidate sh_eth_reset()
Date: Thu, 06 Jun 2013 02:50:42 +0400
Message-ID: <51AFC0C2.1050103@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com> <201306060119.30971.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306060119.30971.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/06/2013 01:19 AM, Sergei Shtylyov wrote:

> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>
> This driver has sh_eth_reset() function for each SoC and this functio=
n is almost
> always the same, except for the several a bit different variations fo=
r Gigabit
> Ethernet.  Consolidate every variation into a single function -- whic=
h allows
> us to get rid of some more #ifdef'fery.
>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> [Sergei: moved the new sh_eth_reset() upper to decrease the patch  si=
ze,  fixed
> function call continuation lines' indentation, reworded the changelog=
, reworded
> the subject, changing the prefix.]
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
> Changes in version 4:
> - moved the new sh_eth_reset() upper to desrease the patch size;

Oops, I forgot to test-compile this change:

drivers/net/ethernet/renesas/sh_eth.c: In function =91sh_eth_reset=92:
drivers/net/ethernet/renesas/sh_eth.c:745:2: error: implicit declaratio=
n=20
of function =91sh_eth_is_gether=92 [-Werror=3Dimplicit-function-declara=
tion]
drivers/net/ethernet/renesas/sh_eth.c: At top level:
drivers/net/ethernet/renesas/sh_eth.c:857:12: error: static declaration=
=20
of =91sh_eth_is_gether=92 follows non-static declaration
drivers/net/ethernet/renesas/sh_eth.c:745:6: note: previous implicit=20
declaration of =91sh_eth_is_gether=92 was here
cc1: some warnings being treated as errors
make[1]: *** [drivers/net/ethernet/renesas/sh_eth.o] Error 1
make: *** [drivers/net/ethernet/renesas/sh_eth.o] Error 2

I guess I have to repost the whole series now? :-(

WBR, Sergei

