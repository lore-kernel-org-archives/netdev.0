From: Ben Greear <greearb@candelatech.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Mon, 26 Mar 2012 14:53:36 -0700
Message-ID: <4F70E560.3020102@candelatech.com>
References: <4F70E308.7070908@candelatech.com> <20120326.174945.1186427809261872546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52549 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757364Ab2CZVxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 17:53:40 -0400
In-Reply-To: <20120326.174945.1186427809261872546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2012 02:49 PM, David Miller wrote:
>
> Looks like all of those strange undiagnosable reported Dave Jones
> has been feeding us.  Something in one part of the kernel leaves
> a lock held, and this shows up as a warning elsewhere.

Every (initial) bug printout fingers ipv6 and the 'ip' tool on my system.

And, the bisect clearly points at this commit.

I'm (re)reading the patch top to bottom to see if something
jumps out...and will be happy to liberally sprinkle debug
code if anyone has any suggestions.

Thanks,
Ben

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
