From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] using mii-bitbang on different processor ports -
	update the booting-without-of.txt-file
Date: Tue, 6 Nov 2007 12:46:49 -0600
Message-ID: <20071106184649.GA5283@loki.buserror.net>
References: <1194339117.3467.8.camel@p60635-ste.ids.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Sergej Stepanov <Sergej.Stepanov@ids.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1194339117.3467.8.camel@p60635-ste.ids.de>
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

On Tue, Nov 06, 2007 at 09:51:57AM +0100, Sergej Stepanov wrote:
> The patch updates the booting-without-of.txt-file.
> There is a description for the case
> if mdio data and clock pins are on different processor ports.
> It is a extending for e-mail "[PATCH v3] using mii-bitbang on different processor ports".
> 
> Signed-off-by: Sergej Stepanov <Sergej.Stepanov@ids.de>
> --
> 
> diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
> index a96e853..497d8d8 100644
> --- a/Documentation/powerpc/booting-without-of.txt
> +++ b/Documentation/powerpc/booting-without-of.txt
> @@ -1956,6 +1956,12 @@ platforms are moved over to use the flattened-device-tree model.
>  		fsl,mdc-pin = <13>;
>  	};
>  
> +   The "reg"-property may have also depending on board design
> +   the following form:
> +	reg = <10d40 14 10d60 14>;
> +   In that case the pin for mdio data controlling is on the port C,
> +   and the pin for mdio clock controlling is on the port D.

It'd be better to explicitly say that the first resource is mdio, and the
second resource is mdc, rather than require the reader to know/look up which
corresponds to 10d40 and which to 10d60.

-Scott
