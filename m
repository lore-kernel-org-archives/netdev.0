From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/3] ipip: Properly mark ipip GRO packets as
 encapsulated.
Date: Thu, 17 Mar 2016 15:29:09 -0700
Message-ID: <1458253749.31963.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458239136-37814-1-git-send-email-jesse@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick Boutilier <boutilpj@ednet.ns.ca>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36696 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364AbcCQW3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 18:29:12 -0400
Received: by mail-pf0-f173.google.com with SMTP id u190so138780534pfb.3
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 15:29:12 -0700 (PDT)
In-Reply-To: <1458239136-37814-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-17 at 11:25 -0700, Jesse Gross wrote:
> ipip encapsulated packets can be merged together by GRO but the result
> does not have the proper GSO type set or even marked as being
> encapsulated at all. Later retransmission of these packets will likely
> fail if the device does not support ipip offloads. This is similar to
> the issue resolved in IPv6 sit in feec0cb3
> ("ipv6: gro: support sit protocol").
> 
> Reported-by: Patrick Boutilier <boutilpj@ednet.ns.ca>
> Fixes: 9667e9bb ("ipip: Add gro callbacks to ipip offload")
> Signed-off-by: Jesse Gross <jesse@kernel.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
