From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH net-next-2.6] bonding: cleanup module option descriptions
Date: Thu, 26 May 2011 11:35:11 +0800
Message-ID: <4DDDCA6F.80608@gmail.com>
References: <1306334519-20243-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:55446 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233Ab1EZDeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 23:34:31 -0400
Received: by qyg14 with SMTP id 14so156213qyg.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 20:34:30 -0700 (PDT)
In-Reply-To: <1306334519-20243-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2011 10:41 PM, Andy Gospodarek wrote:
> Weiping Pan noticed that the module option description for
> xmit_hash_policy was incorrect and was nice enough to post a patch to
> fix it.  The text was correct, but created a line over 80 characters and
> I would rather not add those.  I realized I could take a few minutes and
> clean up all the descriptions and things would look much better.  This
> is the result.
>
> Based on patch from Weiping Pan<panweiping3@gmail.com>.
>
> Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
> CC: Weiping Pan<panweiping3@gmail.com>
>
> ---
>   drivers/net/bonding/bond_main.c |   34 ++++++++++++++++++++++------------
>   1 files changed, 22 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 088fd84..31a61d3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -113,9 +113,11 @@ MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
>   module_param(tx_queues, int, 0);
>   MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
>   module_param_named(num_grat_arp, num_peer_notif, int, 0644);
> -MODULE_PARM_DESC(num_grat_arp, "Number of peer notifications to send on failover event (alias of num_unsol_na)");
> +MODULE_PARM_DESC(num_grat_arp, "Number of peer notifications to send on "
> +			       "failover event (alias of num_unsol_na)");
>   module_param_named(num_unsol_na, num_peer_notif, int, 0644);
> -MODULE_PARM_DESC(num_unsol_na, "Number of peer notifications to send on failover event (alias of num_grat_arp)");
> +MODULE_PARM_DESC(num_unsol_na, "Number of peer notifications to send on "
> +			       "failover event (alias of num_grat_arp)");
>   module_param(miimon, int, 0);
>   MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
>   module_param(updelay, int, 0);
> @@ -127,7 +129,7 @@ module_param(use_carrier, int, 0);
>   MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; "
>   			      "0 for off, 1 for on (default)");
>   module_param(mode, charp, 0);
> -MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
> +MODULE_PARM_DESC(mode, "Mode of operation; 0 for balance-rr, "
>   		       "1 for active-backup, 2 for balance-xor, "
>   		       "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
>   		       "6 for balance-alb");
> @@ -142,27 +144,35 @@ MODULE_PARM_DESC(primary_reselect, "Reselect primary slave "
>   				   "2 for only on active slave "
>   				   "failure");
>   module_param(lacp_rate, charp, 0);
> -MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
> -			    "(slow/fast)");
> +MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner; "
> +			    "0 for slow, 1 for fast");
>   module_param(ad_select, charp, 0);
> -MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
> +MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic; "
> +			    "0 for stable (default), 1 for bandwidth, "
> +			    "2 for count");
>   module_param(xmit_hash_policy, charp, 0);
> -MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
> -				   ", 1 for layer 3+4");
> +MODULE_PARM_DESC(xmit_hash_policy, "balance-xor and 802.3ad hashing method; "
> +				   "0 for layer 2 (default), 1 for layer 3+4, "
> +				   "2 for layer 2+3");
>   module_param(arp_interval, int, 0);
>   MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
>   module_param_array(arp_ip_target, charp, NULL, 0);
>   MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
>   module_param(arp_validate, charp, 0);
> -MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
> +MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes; "
> +			       "0 for none (default), 1 for active, "
> +			       "2 for backup, 3 for all");
>   module_param(fail_over_mac, charp, 0);
> -MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  none (default), active or follow");
> +MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to "
> +				"the same MAC; 0 for none (default), "
> +				"1 for active, 2 for follow");
>   module_param(all_slaves_active, int, 0);
>   MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
> -				     "by setting active flag for all slaves.  "
> +				     "by setting active flag for all slaves; "
>   				     "0 for never (default), 1 for always.");
>   module_param(resend_igmp, int, 0);
> -MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link failure");
> +MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on "
> +			      "link failure");
>
>   /*----------------------------- Global variables ----------------------------*/
>
That look much clearer.

Reviewed-by: Weiping Pan <panweiping3@gmail.com>
