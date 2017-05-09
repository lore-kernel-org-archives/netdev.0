From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] net: wireless: ath: ath9k: remove unnecessary code
Date: Tue, 9 May 2017 11:32:58 +0000
Message-ID: <87efvy1d07.fsf@kamboji.qca.qualcomm.com>
References: <20170509034814.GA18034@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: ath9k-devel <ath9k-devel@qca.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509034814.GA18034@embeddedgus> (Gustavo A. R. Silva's
        message of "Mon, 8 May 2017 22:48:14 -0500")
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva@embeddedor.com> writes:

> The name of an array used by itself will always return the array's addres=
s.
> So this test will always evaluate as true.
>
> Addresses-Coverity-ID: 1364903
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  drivers/net/wireless/ath/ath9k/eeprom.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wirele=
ss/ath/ath9k/eeprom.c
> index fb80ec8..5c3bc28 100644
> --- a/drivers/net/wireless/ath/ath9k/eeprom.c
> +++ b/drivers/net/wireless/ath/ath9k/eeprom.c
> @@ -143,7 +143,7 @@ bool ath9k_hw_nvram_read(struct ath_hw *ah, u32 off, =
u16 *data)
> =20
>  	if (ah->eeprom_blob)
>  		ret =3D ath9k_hw_nvram_read_firmware(ah->eeprom_blob, off, data);
> -	else if (pdata && !pdata->use_eeprom && pdata->eeprom_data)
> +	else if (pdata && !pdata->use_eeprom)
>  		ret =3D ath9k_hw_nvram_read_pdata(pdata, off, data);
>  	else
>  		ret =3D common->bus_ops->eeprom_read(common, off, data);

The patch may very well be valid (didn't check yet) but the commit log
is gibberish for me.

--=20
Kalle Valo=
