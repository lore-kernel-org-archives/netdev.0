From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 V2] forcedeth: fix vlans
Date: Wed, 27 Jul 2011 22:41:35 -0700 (PDT)
Message-ID: <20110727.224135.1053619892675386072.davem@davemloft.net>
References: <CAEP_g=9xVomtnViW=rWYmXqGO_45=N8YhWMHsObBXnWAf9Gh5A@mail.gmail.com>
	<CAHXqBF+qjCzfQmDLdKvanpBuQo1X-zFAr_26SCwVuwbSVwpyPA@mail.gmail.com>
	<20110726201927.GD2475@minipsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, jesse@nicira.com, netdev@vger.kernel.org,
	johnstul@us.ibm.com, w41ter@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804Ab1G1Fln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:41:43 -0400
In-Reply-To: <20110726201927.GD2475@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 26 Jul 2011 22:19:28 +0200

> For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT is
> still set and some pseudorandom vids appear. So check for
> NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set vlan
> mode on probe.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
