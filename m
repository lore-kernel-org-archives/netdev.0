From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH 1/1] Use VPI.VCI notation consistently in solos-pci driver
Date: Sun, 26 Dec 2010 12:13:33 -0800
Message-ID: <4D17A1ED.4080601@redfish-solutions.com>
References: <4D1792D1.4040803@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:58667 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752621Ab0LZUNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Dec 2010 15:13:48 -0500
In-Reply-To: <4D1792D1.4040803@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nix.

My sed script mangled the paths, and after doing a quick check on git.kernel.org I see this one has already been applied... it just hasn't made it back downstream into the openadsl project on SourceForge.


On 12/26/10 11:09 AM, Philip Prindeville wrote:
> Use VPI.VCI notation consistently.
>
> Signed-of-by: Philip Prindeville<philipp@redfish-solutions.com>
> ---
>
> --- a/drivers/atm/solos-pci-0.11/solos-pci.c    2010-12-24 01:07:09.000000000 -0700
> +++ b/drivers/atm/solos-pci-0.11/solos-pci.c    2010-12-24 14:18:45.000000000 -0700
> @@ -734,8 +734,8 @@ void solos_bh(unsigned long card_arg)
>                             le16_to_cpu(header->vci));
>                  if (!vcc) {
>                      if (net_ratelimit())
> -                        dev_warn(&card->dev->dev, "Received packet for unknown VCI.VPI %d.%d on port %d\n",
> -                             le16_to_cpu(header->vci), le16_to_cpu(header->vpi),
> +                        dev_warn(&card->dev->dev, "Received packet for unknown VPI.VCI %d.%d on port %d\n",
> +                             le16_to_cpu(header->vpi), le16_to_cpu(header->vci),
>                               port);
>                      continue;
>                  }
>
>

