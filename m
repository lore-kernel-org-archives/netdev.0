From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/4] inet: frags: use INC_STATS_BH in the ipv6
 reassembly code
Date: Thu, 31 Jul 2014 23:43:53 +0200
Message-ID: <1406843033.13603.4.camel@localhost>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
	 <1406819499-11198-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41909 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751889AbaGaVn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:43:57 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway1.nyi.internal (Postfix) with ESMTP id 7C63221A32
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 17:43:56 -0400 (EDT)
In-Reply-To: <1406819499-11198-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-07-31 at 17:11 +0200, Nikolay Aleksandrov wrote:
> Softirqs are already disabled so no need to do it again, thus let's be
> consistent and use the IP6_INC_STATS_BH variant.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

And I can ack this one. ;)

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
