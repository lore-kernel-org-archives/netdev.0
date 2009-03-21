From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/5] igb: allow tx of pre-formatted vlan
 tagged packets
Date: Sat, 21 Mar 2009 16:55:42 -0700 (PDT)
Message-ID: <20090321.165542.215684221.davem@davemloft.net>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, ajones@riverbed.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38426
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752023AbZCUXzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 19:55:55 -0400
In-Reply-To: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Mar 2009 03:16:31 -0700

> When the 82575 is fed 802.1q packets, it chokes with
> an error of the form:
> 
> igb 0000:08:00.1 partial checksum but proto=81!
 ...
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> +
>  			switch (skb->protocol) {
>  			case cpu_to_be16(ETH_P_IP):
>  				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;

Applied with skb->protocol fixed to be just plain 'protocol'.
