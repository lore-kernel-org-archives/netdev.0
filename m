From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: remove duplicated NLMSG_ALIGN
Date: Tue, 26 Mar 2013 12:40:25 -0400 (EDT)
Message-ID: <20130326.124025.155973913775363457.davem@davemloft.net>
References: <1364274245-20689-1-git-send-email-honkiko@gmail.com>
	<20130326111347.GA20395@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: honkiko@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, zhiguo.hong@emc.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965705Ab3CZQk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:40:28 -0400
In-Reply-To: <20130326111347.GA20395@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 26 Mar 2013 11:13:47 +0000

> On 03/26/13 at 01:04pm, Hong Zhiguo wrote:
>> NLMSG_HDRLEN is already aligned value. It's for directly reference
>> without extra alignment.
>> 
>> The redundant alignment here may confuse the API users.
>> 
>> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
