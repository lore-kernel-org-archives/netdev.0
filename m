From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Regression, bisected: WARNING spam with ipsec since 2.6.35
Date: Fri, 17 Sep 2010 10:19:20 -0400
Message-ID: <20100917141920.GA9280@elliptictech.com>
References: <20100916213138.GA6605@elliptictech.com>
 <1284676070.4784.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1284676070.4784.25.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-09-17 00:27 +0200, Eric Dumazet wrote:
> I suspect following patch is needed, before further changes.
> 
> [PATCH] xfrm: dont assume rcu_read_lock in xfrm_output_one()

Yup, that makes the warnings go away.  Thanks.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
