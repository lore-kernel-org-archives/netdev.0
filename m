From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] Documentation: bindings: net: DPAA corenet binding
 document
Date: Mon, 1 Dec 2014 22:39:49 -0600
Message-ID: <1417495189.15957.209.camel@freescale.com>
References: <1417169426-11823-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>, <Emilian.Medve@freescale.com>,
	<Igal.Liberman@freescale.com>
To: <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0142.outbound.protection.outlook.com ([157.56.111.142]:21953
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752806AbaLBEj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 23:39:58 -0500
In-Reply-To: <1417169426-11823-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-28 at 12:10 +0200, Madalin Bucur wrote:
> Add the device tree binding document for the DPAA corenet node
> and DPAA Ethernet nodes.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
>  Documentation/devicetree/bindings/net/fsl-dpaa.txt | 31 ++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/fsl-dpaa.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-dpaa.txt b/Documentation/devicetree/bindings/net/fsl-dpaa.txt
> new file mode 100644
> index 0000000..822c668
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fsl-dpaa.txt
> @@ -0,0 +1,31 @@
> +*DPAA corenet
> +
> +The corenet bus containing all DPAA Ethernet nodes.

What does this have to do with corenet?

> +Required property
> + - compatible: string property.  Must include "fsl,dpaa". Can include
> +   also "fsl,<SoC>-dpaa".

No need for the <SoC> part.  As we previously discussed, the only
purpose of this node is backwards compatibility with the U-Boot MAC
address fixup -- if U-Boot doesn't look for the <SoC> version, then
don't complicate things.

Though, I can't find where U-Boot references this node.  Are you sure
it's not using the ethernet%d aliases like everything else, in which
case why do we need this node at all?

-Scott
