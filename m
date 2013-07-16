From: David Miller <davem@davemloft.net>
Subject: Re: sysfs_format_mac
Date: Tue, 16 Jul 2013 16:41:15 -0700 (PDT)
Message-ID: <20130716.164115.632329129735253892.davem@davemloft.net>
References: <1374009169.1949.38.camel@joe-AO722>
	<20130716.162549.1211987183945448630.davem@davemloft.net>
	<1374017532.1949.57.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933573Ab3GPXlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 19:41:16 -0400
In-Reply-To: <1374017532.1949.57.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 16 Jul 2013 16:32:12 -0700

> On Tue, 2013-07-16 at 16:25 -0700, David Miller wrote:
>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> []
>>  ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
> []
>> -       l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
>> -       l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
> []
>> +       return scnprintf(buf, PAGE_SIZE, "%*phC", len, addr);
> 
> missing newline?
> 
> 	scnprintf(buf, PAGE_ SIZE, "%*phC\n", len, addr);

Good catch.
