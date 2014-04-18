From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/4] Documentation: dts: Add bindings for APM X-Gene
 SoC ethernet driver
Date: Fri, 18 Apr 2014 23:51:07 +0400
Message-ID: <5351822B.7010402@cogentembedded.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com> <1397271984-23405-3-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:56273 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbaDRTvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 15:51:07 -0400
Received: by mail-lb0-f174.google.com with SMTP id u14so1634139lbd.33
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 12:51:06 -0700 (PDT)
In-Reply-To: <1397271984-23405-3-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/12/2014 07:06 AM, Iyappan Subramanian wrote:

> This patch adds documentation for APM X-Gene SoC ethernet DTS binding.

> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Ravi Patel <rapatel@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> ---
>   .../devicetree/bindings/net/apm-xgene-enet.txt     |   46 ++++++++++++++++++++
>   1 file changed, 46 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt

> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> new file mode 100644
> index 0000000..0c983e8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> @@ -0,0 +1,46 @@
> +APM X-Gene SoC Ethernet nodes
> +
> +Ethernet nodes are defined to describe on-chip ethernet interfaces in
> +APM X-Gene SoC.
> +
> +Required properties:
> +- compatible		: Should be "apm,xgene-enet"
> +- reg			: First resource is the ethernet base register set
> +			  Second resource is the ring base register set
> +			  Third resource is the ring command register set
> +- interrupts		: Ethernet main interrupt
> +- clocks		: Reference to the clock entry.
> +- local-mac-address	: Ethernet MAC address.

    This property is described in 
Documentation/devicetree/bindings/net/ethernet.txt, please refer to it.

> +- phy-addr		: Ethernet MII phy address.

    No, thus won't do. Please use "phy-handle" property to refer to a PHY subnode.

> +- phy-mode		: Ethernet MII mode.

    This one is described in 
Documentation/devicetree/bindings/net/ethernet.txt as well.

WBR, Sergei
