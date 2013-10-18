From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/9] Introduce support to lazy initialize
 mostly static keys
Date: Fri, 18 Oct 2013 16:32:01 -0400 (EDT)
Message-ID: <20131018.163201.1946075086732460816.davem@davemloft.net>
References: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 17 Oct 2013 07:31:54 +0200

> This series implements support for delaying the initialization of secret
> keys, e.g. used for hashing, for as long as possible. This functionality
> is implemented by a new macro, net_get_random_bytes.
> 
> I already used it to protect the socket hashes, the syncookie secret
> (most important) and the tcp_fastopen secrets.

I generally have no problem with this series and like how it improves the
secret being input on the ipv6 side.

Please address the commit message feedback and respin this series.

Thanks.
