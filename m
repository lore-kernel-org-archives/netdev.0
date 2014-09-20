From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: mld: answer mldv2 queries with mldv1 reports
 in mldv1 fallback
Date: Sat, 20 Sep 2014 15:36:13 +0200
Message-ID: <1411220173.3064805.169748713.764DF711@webmail.messagingengine.com>
References: <1411214635-14136-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:57796 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401AbaITNgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 09:36:13 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 3925D20756
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 09:36:13 -0400 (EDT)
In-Reply-To: <1411214635-14136-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2014, at 14:03, Daniel Borkmann wrote:
> Since the mapping of MRC to MRD in exactly such cases can make use of
> the exponential algorithm from 5.1.3, we cannot [strictly speaking] be
> aware in MLDv1 of the encoding in MRC, it seems also not mentioned by
> the RFC. Since encodings are the same up to 32767, assume in such a
> situation this value as a hard upper limit we would clamp. We have asked
> one of the RFC authors on that regard, and he mentioned that there seem
> not to be any implementations that make use of that exponential algorithm
> on startup messages. In any case, this patch fixes this MLD
> interoperability issue.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
