From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/4] GRE: Use flow based tunneling for OVS
 GRE vport.
Date: Mon, 10 Aug 2015 14:04:08 -0700 (PDT)
Message-ID: <20150810.140408.926257242978429230.davem@davemloft.net>
References: <1439016590-15486-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932575AbbHJVEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:04:09 -0400
In-Reply-To: <1439016590-15486-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri,  7 Aug 2015 23:49:50 -0700

> Following patches make use of new Using GRE tunnel meta data
> collection feature. This allows us to directly use netdev
> based GRE tunnel implementation. While doing so I have
> removed GRE demux API which were targeted for OVS. Most
> of GRE protocol code is now consolidated in ip_gre module.
> 
> v5-v4:
> Fixed Kconfig dependency for vport-gre module.
> 
> v3-v4:
> Added interface to ip-gre device to enable meta data collection.
> While doing this I split second patch into two patches.
> 
> v2-v3:
> Add API to create GRE flow based device.

Series applied, thanks.
