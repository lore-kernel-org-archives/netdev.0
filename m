From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch] bonding: clean up netpoll code
Date: Wed, 1 Dec 2010 17:06:21 +0800
Message-ID: <20101201090621.GA11366@gondor.apana.org.au>
References: <20101201075043.5741.29172.sendpatchset@localhost.localdomain> <1291190612.2856.481.camel@edumazet-laptop> <4CF606C7.6020606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CF606C7.6020606@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 01, 2010 at 04:26:47PM +0800, Cong Wang wrote:
>
> Is this necessary?
> It is just replacing checking IFF_IN_NETPOLL with netpoll_tx_running(),
> you might need to take a look at the bridge code.

I agree with Eric.  The patch does look pretty scary right now.

Each patch should do one thing and one thing only.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
