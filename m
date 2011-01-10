From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/3] iproute2: ip link: add support for network device
 groups
Date: Mon, 10 Jan 2011 08:47:00 -0800
Message-ID: <20110110084700.17798894@nehalam>
References: <1294659559-22648-1-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51537 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753513Ab1AJQrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 11:47:04 -0500
In-Reply-To: <1294659559-22648-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jan 2011 13:39:16 +0200
Vlad Dogaru <ddvlad@rosedu.org> wrote:

> This patch series adds userspace support for network device groups.
> There is support for setting device groups, listing only interfaces of a
> specific group, and setting basic device parameters for all interfaces
> in a group.
> 
> The patches use the IFLA_GROUP and IFLA_FILTERGROUP messages, for which
> I posted pathes in a different set.
> 
> 
> Vlad Dogaru (3):
>   ip link: add support for setting device groups
>   ip link: support listing devices by group
>   ip link: support setting device parameters by group
> 
>  include/linux/if_link.h   |    3 ++
>  include/linux/netdevice.h |    2 +-
>  include/utils.h           |    3 +-
>  ip/ipaddress.c            |   14 +++++++++++
>  ip/iplink.c               |   54 +++++++++++++++++++++++++++++++++++++++++++-
>  ip/link_veth.c            |    3 +-
>  6 files changed, 74 insertions(+), 5 deletions(-)

I like the idea, but I wonder if we should take it farther?
Should it be hierarchal tree of groups?
Should slave devices (ppp, vlan, etc) be automatically assigned
to group of parent?

