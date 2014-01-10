From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gre_offload: simplify GRE header length
 calculation in gre_gso_segment()
Date: Thu, 09 Jan 2014 18:09:18 -0800
Message-ID: <1389319758.31367.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389318437-17744-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:52859 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbaAJCJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 21:09:21 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so3822922pbc.11
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 18:09:21 -0800 (PST)
In-Reply-To: <1389318437-17744-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 20:47 -0500, Neal Cardwell wrote:
> Simplify the GRE header length calculation in gre_gso_segment().
> Switch to an approach that is simpler, faster, and more general. The
> new approach will continue to be correct even if we add support for
> the optional variable-length routing info that may be present in a GRE
> header.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
