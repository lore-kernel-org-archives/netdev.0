From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next 0/2 v2] net: dsa: remove restriction on platform_device
Date: Mon, 09 Mar 2015 22:34:45 -0700
Message-ID: <54FE8275.8060703@roeck-us.net>
References: <1425936681-31910-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:42077 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbbCJFfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 01:35:37 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YVCpM-0013no-MS
	for netdev@vger.kernel.org; Tue, 10 Mar 2015 05:35:36 +0000
In-Reply-To: <1425936681-31910-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2015 02:31 PM, Florian Fainelli wrote:
> Hi all,
>
> This patch series removes the restriction in DSA to operate exclusively with
> platform_device Ethernet MAC drivers when using Device Tree. This basically
> allows arbitrary Ethernet MAC drivers to be used now in conjunction with
> Device Tree.
>
> The reason was that DSA was using a of_find_device_by_node() which limits
> the device_node to device pointer search exclusively to platform_device,
> in our case, we are interested in doing a "class" research and lookup the
> net_device.
>
> Thanks to Chris Packham for testing this on his platform.
>
> Changes in v2:
>
> - fix build for !CONFIG_OF_NET
>
> Florian Fainelli (2):
>    net: core: add of_find_net_device_by_node()
>    net: dsa: utilize of_find_net_device_by_node
>
>   include/linux/of_net.h |  8 ++++++++
>   include/net/dsa.h      |  1 +
>   net/core/net-sysfs.c   | 25 +++++++++++++++++++++++++
>   net/dsa/dsa.c          | 16 +++++++++++-----
>   4 files changed, 45 insertions(+), 5 deletions(-)
>
Both patches building (and working) fine with !CONFIG_OF_NET.

Guenter
