From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/4] net: add IPv4 routing FIB support for
 switchdev
Date: Mon, 02 Mar 2015 17:31:09 -0500 (EST)
Message-ID: <20150302.173109.749741045898697218.davem@davemloft.net>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com>
	<1425290777-22702-3-git-send-email-sfeldma@gmail.com>
	<54F4E3B8.5020705@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbbCBWbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:31:11 -0500
In-Reply-To: <54F4E3B8.5020705@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Date: Mon, 02 Mar 2015 14:27:04 -0800

> Don't we need ndo's to offload adding/deleting neighbor table entries
> and router interface or gateway addresses?
> Is it expected that the switch driver can program the hardware in
> response to the neighbor update events?

The neighbour layer is used to translate IPv4 nexthop addresses into
MAC addresses.  The neighbour layer sends notifications when neigh
entries change, and that is what the driver listens to in order to
reprogram the hardware when necessary.

The rocker driver implementation of these callbacks should have made
this clear.
