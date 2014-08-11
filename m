From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: Fixes to avoid soft lockup in sunvnet
Date: Mon, 11 Aug 2014 14:08:57 -0700 (PDT)
Message-ID: <20140811.140857.65481151389542468.davem@davemloft.net>
References: <20140810194807.GB5222@oracle.com>
	<20140811.135642.2149726326739266234.davem@davemloft.net>
	<20140811210354.GB20351@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899AbaHKVI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:08:58 -0400
In-Reply-To: <20140811210354.GB20351@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 11 Aug 2014 17:03:54 -0400

> On (08/11/14 13:56), David Miller wrote:
>> 
>> Please don't fix multiple things in one huge patch, split up the
>> changes into separate easily reviewed patches.
> 
> So there were 4 different sources of soft-lockup here, each of them
> was just a few lines of change. Do you really want these as 4 patches?

Absolutely, the different lockup changes have different implications
and different sets of issues to consider.
