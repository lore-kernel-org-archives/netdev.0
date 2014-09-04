From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next 10/11] ARM: Documentation: Update fec dts binding
 doc
Date: Thu, 04 Sep 2014 16:55:05 +0400
Message-ID: <54086129.9050508@cogentembedded.com>
References: <1409776486-1403-1-git-send-email-y> <54078488.68c1420a.3020.7c0dSMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org, Frank Li <Frank.Li@freescale.com>
To: y@shlinux1.ap.freescale.net, b38611@freescale.com,
	davem@davemloft.net, netdev@vger.kernel.org, lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:49007 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaIDMzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 08:55:07 -0400
Received: by mail-lb0-f182.google.com with SMTP id u10so11575830lbd.27
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 05:55:06 -0700 (PDT)
In-Reply-To: <54078488.68c1420a.3020.7c0dSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/4/2014 12:34 AM, y@shlinux1.ap.freescale.net wrote:

> From: Frank Li <Frank.Li@freescale.com>

>      This patch update fec devicetree binding doc that add Optional
>      properties "fsl,num_tx_queues" and "fsl,num_rx_queues".

> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>   Documentation/devicetree/bindings/net/fsl-fec.txt | 6 ++++++
>   1 file changed, 6 insertions(+)

> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index 8a2c7b5..4da148d 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -16,6 +16,12 @@ Optional properties:
>   - phy-handle : phandle to the PHY device connected to this device.
>   - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
>     Use instead of phy-handle.
> +- fsl,num_tx_queues : The property is valid for enet-avb IP, which supports
> +  hw multi queues. Should specify the tx queue number, otherwise set tx queue
> +  number to 1.
> +- fsl,num_rx_queues : The property is valid for enet-avb IP, which supports
> +  hw multi queues. Should specify the rx queue number, otherwise set rx queue
> +  number to 1.

    Hyphens are preferred to underscores in the prop names.

WBR, Sergei
