From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] vrf: vrf_master_ifindex_rcu is not always
 called with rcu read lock
Date: Tue, 18 Aug 2015 14:10:16 -0600
Message-ID: <55D39128.1040804@cumulusnetworks.com>
References: <1439914666-7561-1-git-send-email-razor@blackwall.org> <1439921754-19715-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37138 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbHRUKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 16:10:17 -0400
Received: by igui7 with SMTP id i7so88867293igu.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 13:10:17 -0700 (PDT)
In-Reply-To: <1439921754-19715-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 12:15 PM, Nikolay Aleksandrov wrote:
> diff --git a/include/net/vrf.h b/include/net/vrf.h
> index 3bb4af462ed6..b039850a94a3 100644
> --- a/include/net/vrf.h
> +++ b/include/net/vrf.h
> @@ -34,7 +34,6 @@ struct net_vrf {
>
>
>   #if IS_ENABLED(CONFIG_NET_VRF)
> -/* called with rcu_read_lock() */
>   static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
>   {
>   	struct net_vrf_dev *vrf_ptr;

That comment is true for this version.

David
