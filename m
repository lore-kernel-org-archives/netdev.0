From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dcb: fix small regression in __dcbnl_pg_setcfg()
Date: Thu, 21 Jun 2012 15:06:14 -0700 (PDT)
Message-ID: <20120621.150614.1100069075307116721.davem@davemloft.net>
References: <20120621055621.14148.42206.stgit@jf-dev1-dcblab>
	<20120621105245.GI27921@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	lucy.liu@intel.com, alexander.h.duyck@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399Ab2FUWGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 18:06:15 -0400
In-Reply-To: <20120621105245.GI27921@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 21 Jun 2012 06:52:45 -0400

> On Wed, Jun 20, 2012 at 10:56:21PM -0700, John Fastabend wrote:
>> A small regression was introduced in the reply command of
>> dcbnl_pg_setcfg(). User space apps may be expecting the
>> DCB_ATTR_PG_CFG attribute to be returned with the patch
>> below TX or RX variants are returned.
>> 
>> commit 7be994138b188387691322921c08e19bddf6d3c5
>> Author: Thomas Graf <tgraf@suug.ch>
>> Date:   Wed Jun 13 02:54:55 2012 +0000
>> 
>>     dcbnl: Shorten all command handling functions
>> 
>> This patch reverts this behavior and returns DCB_ATTR_PG_CFG
>> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
