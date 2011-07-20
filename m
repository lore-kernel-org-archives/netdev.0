From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: [PATCH 2/3] wireless: ath9k: use %pM to print MAC
Date: Wed, 20 Jul 2011 20:30:21 +0530
Message-ID: <CAD2nsn2tOJTcOo=OcUp-agYCkBNT5Rt2j0D1+E1m1C56+QdQ-A@mail.gmail.com>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
	<e9d4e9e2edf4c51412c141140d51e9baf9ff13a3.1311162926.git.andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <e9d4e9e2edf4c51412c141140d51e9baf9ff13a3.1311162926.git.andriy.shevchenko@linux.intel.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 20, 2011 at 7:04 PM, Andy Shevchenko
<andriy.shevchenko@linux.intel.com> wrote:
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>
> Cc: ath9k-devel@lists.ath9k.org
> ---
> =A0drivers/net/wireless/ath/ath9k/htc_drv_debug.c | =A0 =A07 ++-----
> =A01 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/net=
/wireless/ath/ath9k/htc_drv_debug.c
> index aa48b3a..d3ff33c 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
> @@ -623,11 +623,8 @@ static ssize_t read_file_base_eeprom(struct file *fi=
le, char __user *user_buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pBase9287-=
>openLoopPwrCntl);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 len +=3D snprintf(buf + len, size - len,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%20s : %02X:%02X:%02X:%02X=
:%02X:%02X\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "MacAddress",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pBase->macAddr[0], pBase->m=
acAddr[1], pBase->macAddr[2],
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pBase->macAddr[3], pBase->m=
acAddr[4], pBase->macAddr[5]);
> + =A0 =A0 =A0 len +=3D snprintf(buf + len, size - len, "%20s : %pM\n", "M=
acAddress",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pBase->macAddr);
> =A0 =A0 =A0 =A0if (len > size)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D size;

thanks for the patch!

>
> --
> 1.7.5.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



-- =

shafi
