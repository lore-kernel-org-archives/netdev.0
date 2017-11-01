From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: display hw address of source machine
 during ipv6 DAD failure
Date: Wed, 01 Nov 2017 20:54:01 +0900 (KST)
Message-ID: <20171101.205401.58455654476717666.davem@davemloft.net>
References: <1509406732-21855-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, dsahern@gmail.com,
        netdev@vger.kernel.org, ilubashe@akamai.com, pai.vishwain@gmail.com
To: vpai@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdKALyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 07:54:05 -0400
In-Reply-To: <1509406732-21855-1-git-send-email-vpai@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vishwanath Pai <vpai@akamai.com>
Date: Mon, 30 Oct 2017 19:38:52 -0400

> This patch updates the error messages displayed in kernel log to include
> hwaddress of the source machine that caused ipv6 duplicate address
> detection failures.
> 
> Examples:
> 
> a) When we receive a NA packet from another machine advertising our
> address:
> 
> ICMPv6: NA: 34:ab:cd:56:11:e8 advertised our address 2001:db8:: on eth0!
> 
> b) When we detect DAD failure during address assignment to an interface:
> 
> IPv6: eth0: IPv6 duplicate address 2001:db8:: used by 34:ab:cd:56:11:e8
> detected!
> 
> v2:
>     Changed %pI6 to %pI6c in ndisc_recv_na()
>     Chaged the v6 address in the commit message to 2001:db8::
> 
> Suggested-by: Igor Lubashev <ilubashe@akamai.com>
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>

Applied, thank you.
