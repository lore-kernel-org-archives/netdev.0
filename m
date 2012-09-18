From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next 0/4] ipv6: fix the reassembly expire code in
 nf_conntrack
Date: Tue, 18 Sep 2012 11:04:06 +0800
Message-ID: <1347937446.14402.17.camel@cr0>
References: <1347935656.14402.12.camel@cr0>
	 <20120917.223559.1226100441781312938.davem@davemloft.net>
	 <1347936443.14402.15.camel@cr0>
	 <20120917.225304.1071254088219136410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120917.225304.1071254088219136410.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-09-17 at 22:53 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 18 Sep 2012 10:47:23 +0800
> 
> > I will remove this #ifdef and resend the whole patchset.
> 
> Or, alternatively, use IS_ENABLED() or a similar test which will take
> the modular case into account.
> 

Yeah, actually net->ipv6 is also defined with #if
IS_ENABLED(CONFIG_IPV6), so IS_ENABLED() is the right fix.

Thanks!

