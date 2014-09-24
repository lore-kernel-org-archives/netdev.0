From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/3] ipv6: mld: remove duplicate code from
 mld_update_qri
Date: Wed, 24 Sep 2014 22:36:58 +0200
Message-ID: <1411591018.2487738.171400713.754C3607@webmail.messagingengine.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
 <1411455828-5196-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49274 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751351AbaIXUg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:36:59 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 0931D20AE2
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 16:36:59 -0400 (EDT)
In-Reply-To: <1411455828-5196-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014, at 09:03, Daniel Borkmann wrote:
> The QRI (Query Response Interval) from RFC3810, section 9.3. is the same
> as we calculate anyway earlier. Therefore, we can just remove that code
> and simply reuse the value of max_delay.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
