From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: hash net ptr into fragmentation bucket
 selection
Date: Wed, 25 Mar 2015 15:04:08 +0100
Message-ID: <1427292248.2314082.245061945.6A153FEF@webmail.messagingengine.com>
References: <8d98fd0e002553538fb43e5fcafff38f3d65153f.1427291651.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Flavio Leitner <fbl@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52275 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932096AbbCYOEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 10:04:08 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 8FBF920D52
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:04:05 -0400 (EDT)
In-Reply-To: <8d98fd0e002553538fb43e5fcafff38f3d65153f.1427291651.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015, at 15:00, Hannes Frederic Sowa wrote:
> As namespaces are sometimes used with overlapping ip address ranges,
> we should also use the namespace as input to the hash to select the ip
> fragmentation counter bucket.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Oh, the rebase broke. Sending v2.
