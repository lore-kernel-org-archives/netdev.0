From: Rhyland Klein <rklein@nvidia.com>
Subject: Re: [PATCH 0/5] rfkill-gpio: ACPI support
Date: Wed, 16 Oct 2013 12:13:36 -0400
Message-ID: <525EBB30.5030602@nvidia.com>
References: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate16.nvidia.com ([216.228.121.65]:6365 "EHLO
	hqemgate16.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873Ab3JPQNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:13:38 -0400
In-Reply-To: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 6:53 AM, Heikki Krogerus wrote:
> Hi,
> 
> The first patches prepare the driver for the support. The last patch
> can then add the support quite easily. With these patches, adding DT
> support later will be quite straight forward if someone needs it.
> 
> 
> Heikki Krogerus (5):
>   net: rfkill: gpio: convert to resource managed allocation
>   net: rfkill: gpio: clean up clock handling
>   net: rfkill: gpio: spinlock-safe GPIO access
>   net: rfkill: gpio: prepare for DT and ACPI support
>   net: rfkill: gpio: add ACPI support
> 
>  net/rfkill/Kconfig       |   2 +-
>  net/rfkill/rfkill-gpio.c | 211 ++++++++++++++++++++++-------------------------
>  2 files changed, 99 insertions(+), 114 deletions(-)
> 

Strictly speaking, duplicating the pdata fields into the
rfkill_gpio_data structure isn't really necessary. Many drivers simply
have the dt parsing or in this case ACPI parsing generate a
platform_data structure which would then be saved in the
rfkill_gpio_data structure.

In this case, since it is only a few fields, I am not too worried and I
am fine either way.

Acked-by: Rhyland Klein <rklein@nvidia.com>

-- 
nvpublic
