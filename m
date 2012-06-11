From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip: speedup ip link
Date: Mon, 11 Jun 2012 14:57:19 -0700
Message-ID: <20120611145719.6337066e@nehalam.linuxnetplumber.net>
References: <1339242955.7575.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33788 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab2FKV5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 17:57:22 -0400
In-Reply-To: <1339242955.7575.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 09 Jun 2012 13:55:55 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> ip link has quadratic behavior because store_nlmsg()
> has a head list pointer and search the end of list.
> 
> Provides a head/tail to cut time.
> 
> Time with 128000 net devices, to do "ip link show dev xxx"
> 
> Before: 2m3.594s
> After: 0m2.830s
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good applied
