From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: fix handling of the inner 8021Q tagged
 frame
Date: Mon, 31 Mar 2014 17:46:56 -0700
Message-ID: <20140331174656.60f7ce3f@nehalam.linuxnetplumber.net>
References: <87a9c6g8l2.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:48110 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaDAAq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 20:46:59 -0400
Received: by mail-pb0-f42.google.com with SMTP id rr13so8993761pbb.15
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 17:46:59 -0700 (PDT)
In-Reply-To: <87a9c6g8l2.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Mar 2014 15:56:09 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> +	ether_addr_copy(key.eth_addr, eth_hdr(skb)->h_source);
> +	if (ntohs(eth_hdr(skb)->h_proto) == ETH_P_8021Q)
> +		key.vlan_id = ntohs(vlan_eth_hdr(skb)->h_vlan_TCI) & VLAN_VID_MASK;
> +	else
> +		key.vlan_id = 0;
> +

What about QinQ vlan's?
