From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Fri, 19 Dec 2014 15:45:59 -0500 (EST)
Message-ID: <20141219.154559.134422023419840492.davem@davemloft.net>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com>
	<20141219121144.5f9899ba@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, sassmann@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaLSUqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 15:46:03 -0500
In-Reply-To: <20141219121144.5f9899ba@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 19 Dec 2014 12:11:44 +0100

> On Thu, 18 Dec 2014 15:58:42 +0530, Govindarajulu Varadarajan wrote:
>> Hardware always provides compliment of IP pseudo checksum. Stack expects
>> whole packet checksum without pseudo checksum if CHECKSUM_COMPLETE is set.
>> 
>> This causes checksum error in nf & ovs.
>> 
>> [...]
>> 
>> Hardware verifies IP & tcp/udp header checksum but does not provide payload
>> checksum, use CHECKSUM_UNNECESSARY. Set it only if its valid IP tcp/udp packet.
>> 
>> Cc: Jiri Benc <jbenc@redhat.com>
>> Cc: Stefan Assmann <sassmann@redhat.com>
>> Reported-by: Sunil Choudhary <schoudha@redhat.com>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> 
> Reviewed-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.
