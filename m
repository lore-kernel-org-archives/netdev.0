From: David Miller <davem@davemloft.net>
Subject: Re: bonding: fix slave speed reporting in bond_miimon_commit
Date: Mon, 24 Jun 2013 00:05:24 -0700 (PDT)
Message-ID: <20130624.000524.686425939788606598.davem@davemloft.net>
References: <1371731653-13568-1-git-send-email-nikolay@redhat.com>
	<20130620134247.GA1157@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab3FXHFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:05:25 -0400
In-Reply-To: <20130620134247.GA1157@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 20 Jun 2013 15:42:48 +0200

> On Thu, Jun 20, 2013 at 02:34:13PM +0200, nikolay@redhat.com wrote:
>>From: Nikolay Aleksandrov <nikolay@redhat.com>
>>
>>When we have BOND_LINK_UP the speed is reported unconditionally with
>>%u
>>format although it can be SPEED_UNKNOWN (-1). After this patch it
>>returns
>>0 in that case in an attempt to keep the existing scripts happy.
>>One line is intenionally left 81 chars because it gets ugly if broken.
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>>
> 
> Acked-by: Veaceslav Falico <vfalico@redhat.com>

Applied.

 
