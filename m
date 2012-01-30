From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Allow ipv6 proxies and arp proxies be shown with
 iproute2
Date: Mon, 30 Jan 2012 13:08:41 -0500 (EST)
Message-ID: <20120130.130841.766082811985560157.davem@davemloft.net>
References: <1327652938-37078-1-git-send-email-antonz@parallels.com>
	<20120127103521.GA21240@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antonz@parallels.com, xemul@parallels.com, devel@openvz.org,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab2A3SKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:10:33 -0500
In-Reply-To: <20120127103521.GA21240@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Fri, 27 Jan 2012 05:35:21 -0500

> On Fri, Jan 27, 2012 at 12:28:58PM +0400, Tony Zelenoff wrote:
>> Add ability to return neighbour proxies list to caller if
>> it sent full ndmsg structure and has NTF_PROXY flag set.
>> 
>> Before this patch (and before iproute2 patches):
>> $ ip neigh add proxy 2001::1 dev eth0
>> $ ip -6 neigh show
>> $
>> 
>> After it and with applied iproute2 patches:
>> $ ip neigh add proxy 2001::1 dev eth0
>> $ ip -6 neigh show
>> 2001::1 dev eth0  proxy
>> $
>> 
>> Compatibility with old versions of iproute2 is not broken,
>> kernel checks for incoming structure size and properly
>> works if old structure is came.
>> 
>> [v2]
>> * changed comments style.
>> * removed useless line with continue and curly bracket.
>> * changed incoming message size check from equal to more or
>>   equal.
>> 
>> CC: davem@davemloft.net
>> CC: kuznet@ms2.inr.ac.ru
>> CC: netdev@vger.kernel.org
>> CC: xemul@parallels.com
>> Signed-off-by: Tony Zelenoff <antonz@parallels.com>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
