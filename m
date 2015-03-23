From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH net-next 2/2] net: neighbour: Document {mcast,ucast}_solicit,
 mcast_resolicit.
Date: Mon, 23 Mar 2015 10:29:25 +0800
Message-ID: <550F7A85.9020901@windriver.com>
References: <20150319.224204.580319871687930153.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ulf.samuelsson@ericsson.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52468 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbbCWC3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 22:29:17 -0400
In-Reply-To: <20150319.224204.580319871687930153.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 09:42 PM, YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> ---
>   Documentation/networking/ip-sysctl.txt | 14 +++++++++++++-
>   1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 4412f69..6c07c2b 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1126,11 +1126,23 @@ arp_accept - BOOLEAN
>   	gratuitous arp frame, the arp table will be updated regardless
>   	if this setting is on or off.
>   
> +mcast_solicit - INTEGER
> +	The maximum number of multicast probes in INCOMPLETE state,
> +	when the associated hardware address is unknown.  Defaults
> +	to 3.
> +
> +ucast_solicit - INTEGER
> +	The maximum number of unicast probes in PROBE state, when
> +	the hardware address is being reconfirmed.  Defaults to 3.
>   
>   app_solicit - INTEGER
>   	The maximum number of probes to send to the user space ARP daemon
>   	via netlink before dropping back to multicast probes (see
> -	mcast_solicit).  Defaults to 0.
> +	mcast_resolicit).  Defaults to 0.
> +
> +mcast_resolicit - INTEGER
> +	The maximum number of multicast probes after unicast and
> +	app probes in PROBE state.  Defaults to 0.
Hi, YOSHIFUJI Hideaki

To be compatible with ipv6, Defaults should be 3.

Best Regards!
Zhu Yanjun

>   
>   disable_policy - BOOLEAN
>   	Disable IPSEC policy (SPD) for this interface
