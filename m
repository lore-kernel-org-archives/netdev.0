From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] tcp: don't extend RTO on failed loss
 probe attempts
Date: Thu, 13 Aug 2015 11:07:36 -0700
Message-ID: <1439489256.7960.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439403499-24774-1-git-send-email-ycheng@google.com>
	 <1439403499-24774-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33736 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbbHMSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 14:07:39 -0400
Received: by pdrh1 with SMTP id h1so22287182pdr.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 11:07:39 -0700 (PDT)
In-Reply-To: <1439403499-24774-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-12 at 11:18 -0700, Yuchung Cheng wrote:
> If TLP was unable to send a probe, it extended the RTO to
> now + icsk_rto. But extending the RTO makes little sense
> if no TLP probe went out. With this commit, instead of
> extending the RTO we re-arm it relative to the transmit time
> of the write queue head.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
