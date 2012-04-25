From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: dcb: add CEE notify calls
Date: Wed, 25 Apr 2012 19:47:28 -0400 (EDT)
Message-ID: <20120425.194728.11446613514701496.davem@davemloft.net>
References: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
	<1335272179.15423.23.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	eilong@broadcom.com, amirv@dev.mellanox.co.il
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab2DYXrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 19:47:33 -0400
In-Reply-To: <1335272179.15423.23.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Tue, 24 Apr 2012 15:56:19 +0300

> 
> On Fri, 2012-04-20 at 12:49 -0700, John Fastabend wrote:
>> This adds code to trigger CEE events when an APP change or setall
>> command is made from user space. This simplifies user space code
>> significantly by creating a single interface to listen on that
>> works with both firmware and userland agents.
>> 
>> And if we end up with multiple agents this keeps every thing in
>> sync userland agents, firmware agents, and kernel notifier consumers.
>> 
>> For an example agent that listens for these events see:
>> 
>> https://github.com/jrfastab/cgdcbxd
>> 
>> cgdcbxd is a daemon used to monitor DCB netlink events and manage
>> the net_prio control group sub-system.
>> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>> 
> 
> Acked-by: Shmulik Ravid <shmulikr@broadcom.com>

Applied, thanks.
