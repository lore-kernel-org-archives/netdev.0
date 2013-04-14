From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: don't bypass encapsulation for multi-
 and broadcasts
Date: Sun, 14 Apr 2013 15:39:50 -0400 (EDT)
Message-ID: <20130414.153950.1876060927096209566.davem@davemloft.net>
References: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab3DNTjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:39:51 -0400
In-Reply-To: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Sun, 14 Apr 2013 12:21:51 +0300

> The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
> and therefore will be sent out bypassing encapsulation. This breaks
> delivery of packets sent to the vxlan multicast group.
> Disabling encapsulation bypass for multicasts and broadcasts fixes the
> issue.
> 
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>

This still won't handle the case of encapsulations occuring in different
namespaces or virtual machines.

I really want this fixed correctly.
