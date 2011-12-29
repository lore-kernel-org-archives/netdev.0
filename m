From: Dirk Behme <dirk.behme@googlemail.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c
Date: Thu, 29 Dec 2011 07:38:28 +0100
Message-ID: <4EFC0AE4.6020608@googlemail.com>
References: <cover.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: =?windows-1252?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>,
 netdev@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1323163127.git.LW@KARO-electronics.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 06.12.2011 11:27, Lothar Wa=DFmann wrote:
> The following set of patches provides some cleanup and bugfixes for
> drivers/net/ethernet/freescale/fec.c and makes the driver buildable as
> a module.
>
> Lothar Wa=C3=9Fmann (8):
>    misc cleanups
>    set con_id in clk_get() call to NULL
>    prevent dobule restart of interface on FDX/HDX change
>    don't request invalid IRQ
>    don't munge MAC address from platform data
>    preserve MII/RMII setting in fec_stop()
>    fix the .remove code
>    make FEC driver buildable as module
>
>   drivers/net/ethernet/freescale/Kconfig |    2 +-
>   drivers/net/ethernet/freescale/fec.c   |   63 ++++++++++++++++++++++---=
-------
>   2 files changed, 44 insertions(+), 21 deletions(-)

What's the status of this patch series?

If I remember correctly, most of them got an Ack or Tested-by from =

Shawn? But one or two need an update (not sure, though)? And the =

subject should be updated?

Best regards

Dirk
