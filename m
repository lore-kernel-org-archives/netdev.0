From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2] using mii-bitbang on different processor ports
Date: Tue, 30 Oct 2007 13:23:42 -0500
Message-ID: <472776AE.2060009@freescale.com>
References: <1193767812.6244.46.camel@p60635-ste.ids.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Sergej Stepanov <Sergej.Stepanov@ids.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1193767812.6244.46.camel@p60635-ste.ids.de>
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

Sergej Stepanov wrote:
> +	if( !of_address_to_resource(np, 1, &res[1])) {

The spacing is still wrong.

> -	iounmap(bitbang->dir);
> +	if ( bitbang->mdio.dir != bitbang->mdc.dir)
> +		iounmap(bitbang->mdio.dir);
> +	iounmap(bitbang->mdc.dir);

And here.

-Scott
