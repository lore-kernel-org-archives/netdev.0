From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/2] net: dsa: remove restriction on
 platform_device
Date: Mon, 09 Mar 2015 16:12:07 -0400 (EDT)
Message-ID: <20150309.161207.896677058678728795.davem@redhat.com>
References: <1425927750-23901-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284AbbCIUMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 16:12:48 -0400
In-Reply-To: <1425927750-23901-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  9 Mar 2015 12:02:28 -0700

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

Looks like there is a V2 coming of this series based upon feedback.
