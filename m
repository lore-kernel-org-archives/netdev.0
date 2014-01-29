From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH v2 0/4] OpenCores 10/100 MAC fixes for gigabit environment
Date: Wed, 29 Jan 2014 10:17:46 +0400
Message-ID: <CAMo8BfKwxKZDfwDcezyfAX73UTiSw7Q_u5Ki=0WNXSYRYF5z0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:59517 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaA2GRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 01:17:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed the subject.

On Wed, Jan 29, 2014 at 10:00 AM, Max Filippov <jcmvbkbc@gmail.com> wrote:
> Hello David, Ben, Florian, Chris and everybody,
>
> this series improves ethoc behavior in gigabit environment:
> - first patch introduces two phylib setters for 'advertising' and 'supported'
>   fields of struct phy_device;
> - second patch disables gigabit advertisement in the attached PHY making
>   possible to use gigabit link without any additional setup;
> - third patch adds support to set up MII management bus frequency, adding
>   new fields to platform data and to OF bindings;
> - fourth patch adds basic ethtool support to ethoc driver.
>
> These changes allow to use KC-705 board with 50MHz xtensa core and OpenCores
> 10/100 Mbps MAC connected to gigabit network without any additional setup.
>
> Changes v1->v2:
> - new patch "phy: provide accessors for 'advertising' and 'supported' fields";
> - disable both gigabit advertisement and support;
> - drop MDIO bus frequency configurability, always configure for standard
>   2.5MHz;
> - allow using common clock framework to provide ethoc clock;
> - new patch: "net: ethoc: implement ethtool operations";
> - drop device tree bindings documentation patch until common bindings format
>   for network drivers is decided.
>
> Max Filippov (4):
>   phy: provide accessors for 'advertising' and 'supported' fields
>   net: ethoc: don't advertise gigabit speed on attached PHY
>   net: ethoc: set up MII management bus clock
>   net: ethoc: implement ethtool operations
>
>  drivers/net/ethernet/ethoc.c | 130 ++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/phy.h          |  12 ++++
>  include/net/ethoc.h          |   1 +
>  3 files changed, 141 insertions(+), 2 deletions(-)
>
> --
> 1.8.1.4

-- 
Thanks.
-- Max
