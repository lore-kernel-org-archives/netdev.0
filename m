From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 16:24:33 -0700
Message-ID: <20150825162433.41c111d6@urahara>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
	linux@roeck-us.net, jiri@resnulli.us, sfeldma@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36591 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756143AbbHYXYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:24:22 -0400
Received: by pacgr6 with SMTP id gr6so5540650pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:24:22 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2015 15:50:10 -0700
Florian Fainelli <f.fainelli@gmail.com> wrote:

> Hi all,
> 
> This patch series implements a L2 only interface concept which basically denies
> any kind of IP address configuration on these interfaces, but still allows them
> to be used as configuration end-points to keep using ethtool and friends.
> 
> A cleaner approach might be to finally come up with the concept of net_port
> which a net_device would be a superset of, but this still raises tons of
> questions as to whether we should be modifying userland tools to be able to
> configure/query these interfaces. During all the switch talks/discussions last
> year, it seemed to me like th L2-only interface is closest we have to a
> "network port".
> 
> Comments, flames, flying tomatoes welcome!
> 
> Florian Fainelli (5):
>   net: add IFF_L2_ONLY flag
>   net: ipv4: Skip in_dev initialization for IFF_L2_ONLY interfaces
>   net: ipv6: Skip in6_dev initialization for IFF_L2_ONLY interfaces
>   net: dsa: Flag slave network devices with IFF_L2_ONLY
>   net: dsa: bcm_sf2: Allow disabling tagging protocol
> 
>  drivers/net/dsa/bcm_sf2.c | 16 +++++++++++++---
>  include/uapi/linux/if.h   |  5 ++++-
>  net/dsa/slave.c           |  1 +
>  net/ipv4/devinet.c        |  3 +++
>  net/ipv6/addrconf.c       |  4 ++++
>  5 files changed, 25 insertions(+), 4 deletions(-)
> 

Can you bridge these?
