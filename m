From: tnt@blacksnow.net
Subject: Re: [PATCH v4] FEC - fast ethernet controller for mpc52xx
Date: Thu, 1 Nov 2007 12:31:24 +0100 (CET)
Message-ID: <41915.213.186.37.16.1193916684.squirrel@www.opensources.be>
References: <20071014075511.GC3000@nd47.coderock.org>
	<4713BA1C.2050604@pobox.com>
	<fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com>
	<4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org>
	<47206209.8080109@pobox.com>
	<20071025141035.GG3369@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>
To: "Domen Puncer" <domen.puncer@telargo.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071025141035.GG3369@nd47.coderock.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

> +	while (bcom_buffer_done(priv->tx_dmatsk)) {
> +		struct sk_buff *skb;
> +		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL, NULL);
> +		/* Here (and in rx routines) would be a good place for
> +		 * dma_unmap_single(), but bcom doesn't return bcom_bd of the
> +		 * finished transfer, and _unmap is empty on this platfrom.
> +		 */
> +

Of course bestcomm let's you get back the bcom_bd ... What do you think
your second NULL parameter is for ?
Give it a pointer to a bcom_bd * and it will fill your pointer for you to
point to the bd you just got back.


   Sylvain
