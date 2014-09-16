From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next v3] Open vSwitch
Date: Tue, 16 Sep 2014 16:25:59 -0400 (EDT)
Message-ID: <20140916.162559.345926762747823937.davem@davemloft.net>
References: <1410852209-1456-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaIPU0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:26:01 -0400
In-Reply-To: <1410852209-1456-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 16 Sep 2014 00:23:29 -0700

> Following patches adds recirculation and hash action to OVS.
> First patch removes pointer to stack object. Next three patches
> does code restructuring which is required for last patch.
> Recirculation implementation is changed, according to comments from
> David Miller, to avoid using recursive calls in OVS. It is using
> queue to record recirc action and deferred recirc is executed at
> the end of current actions execution.
> 
> v1-v2:
> Changed subsystem name in subject to openvswitch
> v2-v3:
> Added patch to remove pkt_key pointer from skb->cb.

Pulled, thanks Pravin.
