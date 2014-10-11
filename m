From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH iproute2] netlink: extend buffers to 16K
Date: Sat, 11 Oct 2014 10:00:11 -0700
Message-ID: <1413046811.16385.27.camel@joe-AO725>
References: <1413045793.9362.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0188.hostedemail.com ([216.40.44.188]:49796 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750834AbaJKRAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 13:00:15 -0400
In-Reply-To: <1413045793.9362.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-11 at 09:43 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Starting from linux-3.15 (commit 9063e21fb026, "netlink: autosize skb
> lengths"), kernel is able to send up to 16K in netlink replies.
> 
> This change enables iproute2 commands to get bigger chunks,
> without breaking compatibility with old kernels.

Maybe a #define for the next time it's increased?
