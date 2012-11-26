From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: clean up locking in inet_frag_find()
Date: Sun, 25 Nov 2012 21:43:12 -0800
Message-ID: <1353908592.30446.1136.camel@edumazet-glaptop>
References: <1353907085-30824-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43378 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab2KZFnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 00:43:14 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so5768753iea.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 21:43:14 -0800 (PST)
In-Reply-To: <1353907085-30824-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 13:18 +0800, Cong Wang wrote:
> It is weird to take the read lock outside of inet_frag_find()
> but release it inside... Also, the hash function doesn't
> need this lock.

This patch is wrong. hash needs the lock.
