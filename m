From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_reasm: fix per-netns sysctl
 initialization
Date: Wed, 13 Feb 2013 20:49:47 +0100
Message-ID: <20130213194947.GA3805@localhost>
References: <20130213094810.64691C3A4E@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Amerigo Wang <amwang@redhat.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130213094810.64691C3A4E@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 13, 2013 at 10:46:09AM +0100, Michal Kubecek wrote:
> Adjusting of data pointers in net/netfilter/nf_conntrack_frag6_*
> sysctl table for other namespaces points to wrong netns_frags
> structure and has reversed order of entries.
> 
> Problem introduced by commit c038a767cd69 in 3.7-rc1

Applied, thanks Michal.
