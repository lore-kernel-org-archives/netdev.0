From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering
 infrastructure
Date: Thu, 17 Jan 2013 04:47:37 +0000 (UTC)
Message-ID: <kd7vp9$ptv$1@ger.gmane.org>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
 <1358360289-23249-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52654 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757587Ab3AQEsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 23:48:03 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TvhOd-0008Uh-8E
	for netdev@vger.kernel.org; Thu, 17 Jan 2013 05:48:11 +0100
Received: from 222.221.64.75 ([222.221.64.75])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 05:48:11 +0100
Received: from xiyou.wangcong by 222.221.64.75 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 05:48:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jan 2013 at 18:17 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> +config BRIDGE_VLAN_FILTERING
> +	bool "VLAN filtering"
> +	depends on BRIDGE
> +	depends on VLAN_8021Q
> +	default y

This should default to n, otherwise Linus will complain.

> +	---help---
> +	  If you say Y here, then the Ethernet bridge will be able selectively
> +	  receive and forward traffic based on VLAN information in the packet
> +	  any VLAN information configured on the bridge port or bridge device.

_and_ any VLAN information...? Missed 'and'?
