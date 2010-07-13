From: jamal <hadi@cyberus.ca>
Subject: Re: [patch] net/sched: potential data corruption
Date: Tue, 13 Jul 2010 11:58:14 -0400
Message-ID: <1279036694.16376.0.camel@bigi>
References: <20100713132152.GL5658@bicker>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	matthew@wil.cx
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41047 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756872Ab0GMP6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 11:58:18 -0400
In-Reply-To: <20100713132152.GL5658@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-13 at 15:21 +0200, Dan Carpenter wrote:
> The reset_policy() does:
>         memset(d->tcfd_defdata, 0, SIMP_MAX_DATA);
>         strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);
> 
> In the original code, the size of d->tcfd_defdata wasn't fixed and if
> strlen(defdata) was less than 31, reset_policy() would cause memory
> corruption.
> 
> Please Note:  The original alloc_defdata() assumes defdata is 32
> characters and a NUL terminator while reset_policy() assumes defdata is
> 31 characters and a NUL.  This patch updates alloc_defdata() to match
> reset_policy() (ie a shorter string).  I'm not very familiar with this
> code so please review carefully.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>


Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

