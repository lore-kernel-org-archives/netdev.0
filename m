From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip6_gre: fix endianness errors in ip6gre_err
Date: Wed, 04 Feb 2015 07:44:36 -0800
Message-ID: <1423064676.907.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423059909-15606-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:45261 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877AbbBDPol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 10:44:41 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so2915880iec.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 07:44:39 -0800 (PST)
In-Reply-To: <1423059909-15606-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 15:25 +0100, Sabrina Dubroca wrote:
> info is in network byte order, change it back to host byte order
> before use. In particular, the current code sets the MTU of the tunnel
> to a wrong (too big) value.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
