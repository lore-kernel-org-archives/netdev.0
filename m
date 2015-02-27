From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/3] dtb: change binding name to match with newer firmware DT
Date: Fri, 27 Feb 2015 21:33:34 +0100
Message-ID: <4061014.S4PDWltU3G@wuerfel>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com> <1425067710-14879-3-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	mlangsdo@redhat.com, patches@apm.com,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:63181 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754697AbbB0UeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:34:06 -0500
In-Reply-To: <1425067710-14879-3-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 27 February 2015 12:08:29 Iyappan Subramanian wrote:
> diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> index f1ad9c2..a857794 100644
> --- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
> +++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> @@ -622,7 +622,7 @@
>                 };
>  
>                 sgenet0: ethernet@1f210000 {
> -                       compatible = "apm,xgene-enet";
> +                       compatible = "apm,xgene1-sgenet";
>                         status = "disabled";
>                         reg = <0x0 0x1f210000 0x0 0xd100>,
>                               <0x0 0x1f200000 0x0 0Xc300>,
> 

This will break booting the new dtb on older kernels, right?

You should normally list the most generic model in addition to the
specific one.

	Arnd
