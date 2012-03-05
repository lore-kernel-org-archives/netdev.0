From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] conntrack, suspicious RCU usage
Date: Mon, 5 Mar 2012 18:05:48 +0100
Message-ID: <20120305170548.GA28986@1984>
References: <1330950269-32668-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330950269-32668-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2012 at 01:24:29PM +0100, Hans Schillstrom wrote:
> From: Hans Schillstrom <hans@schillstrom.com>
> 
> Hello Pablo
> I think you lost this patch from Eric, I updated the patch for the 
> latest nf_conntrack_netlink.c 
> 
> Well, __nf_ct_l4proto_find() being out of line and the way we already
> use rcu_read_lock() in this code, it seems following patch is
> the most natural way to cope with these lockdep warnings.

I'll take the previous patch to pass it to current -rc. Thanks Hans.
