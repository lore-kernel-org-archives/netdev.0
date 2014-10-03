From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 3/6] dtb: Add 10GbE node to APM X-Gene SoC device tree
Date: Fri, 3 Oct 2014 13:49:56 +0100
Message-ID: <20141003124956.GI26643@leverpostej>
References: <1412294568-26747-1-git-send-email-isubramanian@apm.com>
 <1412294568-26747-4-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"patches@apm.com" <patches@apm.com>,
	"kchudgar@apm.com" <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:63885 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751282AbaJCMuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 08:50:32 -0400
Content-Disposition: inline
In-Reply-To: <1412294568-26747-4-git-send-email-isubramanian@apm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

[...]

> +		xgenet: ethernet@1f610000 {
> +			compatible = "apm,xgene-enet";
> +			status = "disabled";
> +			reg = <0x0 0x1f610000 0x0 0xd100>,
> +			      <0x0 0x1f600000 0x0 0X400>,
> +			      <0x0 0x18000000 0x0 0X200>;
> +			reg-names = "enet_csr", "ring_csr", "ring_cmd";
> +			interrupts = <0x0 0x60 0x4>;
> +			dma-coherent;
> +			clocks = <&xge0clk 0>;
> +			local-mac-address = [00 01 73 00 00 04];

Apolgoies, I'd missed your reply on this last time. Please use
all-zeroes for the mac address, and have a comment that this will be
overwritten by the bootloader.

Thanks,
Mark.
