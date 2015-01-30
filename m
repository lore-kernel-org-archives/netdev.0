From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/9] rhashtable: simplify rhashtable_remove()
Date: Fri, 30 Jan 2015 16:36:21 +0000
Message-ID: <20150130163621.GA5807@casper.infradead.org>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422603994-5836-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/15 at 07:46am, Patrick McHardy wrote:
> Remove some duplicated code by moving the restart label up a few
> lines. Also use rcu_access_pointer() for the pointer comparison
> instead of rht_dereference_rcu().
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

BTW, everything except the rcu_access_pointer() optimization is
also covered in the "rhashtable fixes" series I posted.
