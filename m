From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next v2] Bring sizeof(net_device) down to < 2K
 bytes
Date: Mon, 13 Apr 2015 13:15:31 -0400 (EDT)
Message-ID: <20150413.131531.1483293611941865421.davem@davemloft.net>
References: <cover.1428672434.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	daniel@iogearbox.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbbDMRPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:15:33 -0400
In-Reply-To: <cover.1428672434.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 10 Apr 2015 15:52:36 +0200

> The size of struct net_device crossed the 2K boundary a while ago which
> is a waste in combination with many net namespaces. This series brings
> the size of struct net_device down to well below 2K in total size with
> a typical configuration. Some reserves a several holes leave room for
> further expansion.
> 
> Before:
> /* size: 2176, cachelines: 34, members: 121 */
> 
> After:
> /* size: 1984, cachelines: 31, members: 120 */

Series applied, thanks Thomas
