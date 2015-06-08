From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 2/3] VRF driver and needed infrastructure
Date: Mon, 08 Jun 2015 13:08:16 -0600
Message-ID: <5575E820.20700@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36689 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbbFHTIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:08:19 -0400
Received: by ieclw1 with SMTP id lw1so104926017iec.3
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 12:08:18 -0700 (PDT)
In-Reply-To: <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/15 12:35 PM, Shrijeet Mukherjee wrote:
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 019fcef..27a333c 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -283,6 +283,12 @@ config NLMON
>   	  diagnostics, etc. This is mostly intended for developers or support
>   	  to debug netlink issues. If unsure, say N.
>
> +config NET_VRF
> +	tristate "Virtual Routing and Forwarding (Lite)"
> +	---help---
> +          This option enables the support for mapping interfaces into VRF's. The
> +          support enables VRF devices
> +
>   endif # NET_CORE
>
>   config SUNGEM_PHY

I think you need:

depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES

David
