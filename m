From: Patrick McHardy <kaber@trash.net>
Subject: Re: [VLAN] set_rx_mode support for unicast address list
Date: Thu, 24 Jan 2008 18:27:31 +0100
Message-ID: <4798CA83.4080203@trash.net>
References: <20080124160738.11781.23745.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Leech <christopher.leech@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48281 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbYAXR1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 12:27:36 -0500
In-Reply-To: <20080124160738.11781.23745.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Leech wrote:
> Reuse the existing logic for multicast list synchronization for the unicast
> address list. The core of dev_mc_sync/unsync are split out as
> __dev_addr_sync/unsync and moved from dev_mcast.c to dev.c.  These are then
> used to implement dev_unicast_sync/unsync as well.
> 
> I'm working on cleaning up Intel's FCoE stack, which generates new MAC
> addresses from the fibre channel device id assigned by the fabric as per the
> current draft specification in T11.  When using such a protocol in a VLAN
> environment it would be nice to not always be forced into promiscuous mode,
> assuming the underlying Ethernet driver supports multiple unicast addresses as
> well.


Looks good, applied. Thanks Chris.
