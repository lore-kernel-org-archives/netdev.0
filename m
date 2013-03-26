From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] netlink: remove duplicated NLMSG_ALIGN
Date: Tue, 26 Mar 2013 11:13:47 +0000
Message-ID: <20130326111347.GA20395@casper.infradead.org>
References: <1364274245-20689-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, zhiguo.hong@emc.com
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51517 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab3CZLNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:13:50 -0400
Content-Disposition: inline
In-Reply-To: <1364274245-20689-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/13 at 01:04pm, Hong Zhiguo wrote:
> NLMSG_HDRLEN is already aligned value. It's for directly reference
> without extra alignment.
> 
> The redundant alignment here may confuse the API users.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Acked-by: Thomas Graf <tgraf@suug.ch>

This is actually an obsoleted API that we only want to keep around
for backwards compatibility with user space. It would be great to
replace all in kernel usages of NLMSG_LENGTH() with the type safe
variants nlmsg_*() in <net/netlink.h>
