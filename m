From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 21:25:28 +0900
Message-ID: <44C8B0B8.2010408@miyazawa.org>
References: <20060727112531.GN6026@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:19603 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1751087AbWG0M0p
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 08:26:45 -0400
To: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
In-Reply-To: <20060727112531.GN6026@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm interested in the approach. And I have a couple of comments.
I think DAD and ND are time critical operations.
Can the daemons process with confirming to the specs.
even if it were swapped out?
Can we prevent the oom killer from killing the daemons?

Anyway, we have to consider Pros. and Cons of the approach.

Regards,

Hugo Santos wrote:
> Hi all,
> 
>    In the same line as some of the recent IPv6 patches being submited
>  for comments, and taking into consideration RFCs such as 'SEcure
>  Neighbor Discovery (SEND)' (RFC 3971) and 'Cryptographically Generated
>  Addresses (CGA)' (RFC 3972) where the complexity associated with
>  maintaining addresses and performing neighbor discovering increases
>  considerably, what would be the possibility of inclusion of code that
>  would allow the outsource of address configuration, DAD and neighbor
>  discovery to a user-space control application (being that the first two
>  can already be somewhat outsourced)? Of course that the final decision
>  is always based on the patch itself but i would like to probe the
>  developers about the possibility of ever merging such code. Personally
>  i believe that this kind of control logic should always be in
>  user-space to allow for greater flexibility -- but i'm aware that lots
>  of people prefer to have it in kernel to minimize deployment
>  dependencies.
> 
>     Comments?
> 
>     Hugo

--
Kazunori Miyazawa
