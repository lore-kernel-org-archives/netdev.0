From: Stephane Grosjean <s.grosjean@peak-system.com>
Subject: Re: [PATCH] net: can: sja1000: peak_pcmcia.c:  Cleaning up missing
 null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 10:02:24 +0200
Message-ID: <54169D10.6040104@peak-system.com>
References: <1410715833-15809-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410715833-15809-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>

Le 14/09/2014 19:30, Rickard Strandqvist a =E9crit :
> Replacing strncpy with strlcpy to avoid strings that lacks null termi=
nate.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigit=
al.se>
> ---
>   drivers/net/can/sja1000/peak_pcmcia.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/=
sja1000/peak_pcmcia.c
> index dd56133..fc9f8b01 100644
> --- a/drivers/net/can/sja1000/peak_pcmcia.c
> +++ b/drivers/net/can/sja1000/peak_pcmcia.c
> @@ -487,7 +487,7 @@ static void pcan_free_channels(struct pcan_pccard=
 *card)
>   		if (!netdev)
>   			continue;
>  =20
> -		strncpy(name, netdev->name, IFNAMSIZ);
> +		strlcpy(name, netdev->name, IFNAMSIZ);
>  =20
>   		unregister_sja1000dev(netdev);
>  =20

--
PEAK-System Technik GmbH, Otto-Roehm-Strasse 69, D-64293 Darmstadt=20
Geschaeftsleitung: A.Gach/U.Wilhelm,St.Nr.:007/241/13586 FA Darmstadt=20
HRB-9183 Darmstadt, Ust.IdNr.:DE 202220078, WEE-Reg.-Nr.: DE39305391=20
Tel.+49 (0)6151-817320 / Fax:+49 (0)6151-817329, info@peak-system.com
--
