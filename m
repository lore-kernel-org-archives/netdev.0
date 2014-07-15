From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines configurable
 at build
Date: Tue, 15 Jul 2014 21:11:51 +0400
Message-ID: <53C560D7.5020308@cogentembedded.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com> <1405419341-31510-3-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:54792 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbaGORLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:11:50 -0400
Received: by mail-lb0-f176.google.com with SMTP id w7so3739505lbi.21
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:11:48 -0700 (PDT)
In-Reply-To: <1405419341-31510-3-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/15/2014 02:15 PM, Veaceslav Falico wrote:

> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>   drivers/net/bonding/Kconfig   | 16 ++++++++++++++++
>   drivers/net/bonding/bonding.h |  6 +++---
>   2 files changed, 19 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/bonding/Kconfig b/drivers/net/bonding/Kconfig
> index 7b1a0fa..28fb3af 100644
> --- a/drivers/net/bonding/Kconfig
> +++ b/drivers/net/bonding/Kconfig
> @@ -15,3 +15,19 @@ menuconfig BONDING
>
>   	  To compile this driver as a module, choose M here: the module
>   	  will be called bonding.
> +
> +if BONDING
> +
> +config BOND_MAX_VLAN_ENCAP
> +	int "Maximum number of stacked vlans on top of bonding"

    s/vlans/VLANs/?

> +	default "2"
> +
> +config BOND_MAX_ARP_TARGETS
> +	int "Maximum number of ip targets arp monitor supports"

    s/ip/IP/, s/arp/ARP/?

WBR, Sergei
