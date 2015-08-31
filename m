From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: Add support for IFLA_BR_VLAN_PROTOCOL
 attribute
Date: Mon, 31 Aug 2015 16:36:15 -0700
Message-ID: <20150831163615.7b659912@urahara>
References: <1441014526-4818-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33360 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbbHaXgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 19:36:04 -0400
Received: by paczk9 with SMTP id zk9so6161364pac.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 16:36:03 -0700 (PDT)
In-Reply-To: <1441014526-4818-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Aug 2015 18:48:46 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> This patch adds support for bridge vlan_protocol.
> 
> Example:
> $ ip link set br0 type bridge vlan_protocol 802.1ad
> $ ip -d link show br0
> 4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
> UP mode DEFAULT group default qlen 1000
>     link/ether 44:37:e6:ab:cd:ef brd ff:ff:ff:ff:ff:ff promiscuity 0
>     bridge forward_delay 0 hello_time 200 max_age 2000 ageing_time 30000
> stp_state 0 priority 32768 vlan_filtering 0 vlan_protocol 802.1ad
> addrgenmode eui64
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied to net-next branch
