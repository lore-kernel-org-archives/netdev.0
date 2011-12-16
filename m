From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: nonlocal_bind and IPv6
Date: Fri, 16 Dec 2011 15:46:34 +0900
Message-ID: <4EEAE94A.5050400@linux-ipv6.org>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39204 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750985Ab1LPGwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 01:52:36 -0500
In-Reply-To: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have you tried to send packets from the application on node with
local_bind enabled (without the address the application binds)?

Vincent Bernat wrote:
> This is a second tentative to port ip_nonlocal_bind to IPv6. The two
> patches are independant. The first patch enables
> net.ipv6.ip_nonlocal_bind and is "namespace aware". The second patch
> modifies net.ipv4.ip_nonlocal_bind to also be "namespace aware". I
> don't know if this is something important.
> 
> I did not test the SCTP part of the second patch (but it compiles).
> 
>   Documentation/networking/ip-sysctl.txt |    5 +++++
>   include/net/netns/ipv4.h               |    1 +
>   include/net/netns/ipv6.h               |    1 +
>   net/ipv4/af_inet.c                     |    6 +-----
>   net/ipv4/ping.c                        |    2 +-
>   net/ipv4/sysctl_net_ipv4.c             |   16 +++++++++-------
>   net/ipv6/af_inet6.c                    |    6 ++++--
>   net/ipv6/sysctl_net_ipv6.c             |    8 ++++++++
>   net/sctp/protocol.c                    |    2 +-
>   9 files changed, 31 insertions(+), 16 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
