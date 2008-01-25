From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch net-2.6.25][IPV4][FIB] fix fib_proc compilation error
Date: Fri, 25 Jan 2008 08:30:32 -0800
Message-ID: <20080125083032.4a4d5e92@deepthought>
References: <4799E489.90008@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42749 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbYAYQas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 11:30:48 -0500
In-Reply-To: <4799E489.90008@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 EBOGUSWHITESPACE

> +static inline void fib_proc_exit(struct net *net)
> +{
> +	return ;
> +}
>  #endif

Whole patch is unnecessary, since the fib_proc_init is gone in the tree
going into 2.6.25
