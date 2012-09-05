From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [V2 PATCH 6/9] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Wed, 5 Sep 2012 09:33:05 -0700
Message-ID: <20120905093305.2418eac8@nehalam.linuxnetplumber.net>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
	<1346848442-4573-7-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org,
	chethan@chelsio.com
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33294 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999Ab2IEQdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 12:33:32 -0400
In-Reply-To: <1346848442-4573-7-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  5 Sep 2012 18:03:59 +0530
Naresh Kumar Inna <naresh@chelsio.com> wrote:

> +
> +#define	CSIO_ASSERT(cond)						\
> +do {									\
> +	if (unlikely(!((cond))))					\
> +		BUG();                                                  \
> +} while (0)
> +

Why is this not just BUG_ON(!(cond)) ?
