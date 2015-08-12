From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 2/2] iplink: bridge: add support for
 IFLA_BR_VLAN_FILTERING attribute
Date: Wed, 12 Aug 2015 09:21:32 -0700
Message-ID: <20150812092132.670d0b5f@urahara>
References: <1439297784-1962-1-git-send-email-razor@blackwall.org>
	<1439297784-1962-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33869 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbbHLQV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:21:29 -0400
Received: by pawu10 with SMTP id u10so17673205paw.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:21:29 -0700 (PDT)
In-Reply-To: <1439297784-1962-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Aug 2015 15:56:24 +0300
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch implements support for the IFLA_BR_VLAN_FILTERING attribute
> in iproute2 so it can enable/disable vlan_filtering.
> 
> Example:
> $ ip link set br0 type bridge vlan_filtering 1
> $ ip -d link show br0
> 6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
> UP mode DEFAULT group default
>     link/ether 08:00:27:ea:07:38 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     bridge forward_delay 1500 hello_time 200 max_age 2000 vlan_filtering 1
>     addrgenmode eui64
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
Please update man page as well.
