From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack: consolidate lock/unlock into
 unlock_wait
Date: Tue, 15 Mar 2016 01:11:21 +0100
Message-ID: <20160315001121.GA24820@salvia>
References: <1457955542-2377-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457955542-2377-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2016 at 12:39:02PM +0100, Nicholas Mc Guire wrote:
> The spin_lock()/spin_unlock() is synchronizing on the 
> nf_conntrack_locks_all_lock which is equivalent to 
> spin_unlock_wait() but the later should be more efficient.

Applied, thanks.
