From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 0/3] iplink_bridge: add support for
 ageing_time, priority and stp_state
Date: Fri, 26 Jun 2015 00:07:42 -0400
Message-ID: <20150626000742.105a5908@uryu.home.lan>
References: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joerg@higgsboson.tk, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:32794 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbFZELM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 00:11:12 -0400
Received: by oiyy130 with SMTP id y130so67305342oiy.0
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 21:11:11 -0700 (PDT)
In-Reply-To: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jun 2015 13:38:46 +0300
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> Hi,
> Three months ago support was added to be able to set ageing_time,
> priority and stp_state via netlink by commit:
> af615762e972 ("bridge: add ageing_time, stp_state, priority over netlink")
> This patch-set adds support for iproute2 to be able to use them.
> Exampes:
> ip link set dev br0 type bridge priority 10
> ip link set dev br0 type bridge ageing_time 10
> ip link set dev br0 type bridge stp_state 1
> 
> 
> Best regards,
>  Nikolay Aleksandrov
> 
> Nikolay Aleksandrov (3):
>   iplink_bridge: add support for ageing_time
>   iplink_bridge: add support for stp_state
>   iplink_bridge: add support for priority
> 
>  ip/iplink_bridge.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
> 

All these are staged in net-next branch.
