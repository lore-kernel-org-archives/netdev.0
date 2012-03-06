From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 1/1] conntrack, suspicious RCU usage
Date: Tue, 6 Mar 2012 06:58:15 +0100
Message-ID: <201203060658.16156.hans.schillstrom@ericsson.com>
References: <1330950269-32668-1-git-send-email-hans.schillstrom@ericsson.com> <20120305170548.GA28986@1984> <20120305223815.GA30456@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120305223815.GA30456@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 March 2012 23:38:15 Pablo Neira Ayuso wrote:
> On Mon, Mar 05, 2012 at 06:05:48PM +0100, Pablo Neira Ayuso wrote:
> > On Mon, Mar 05, 2012 at 01:24:29PM +0100, Hans Schillstrom wrote:
> > > From: Hans Schillstrom <hans@schillstrom.com>
> > > 
> > > Hello Pablo
> > > I think you lost this patch from Eric, I updated the patch for the 
> > > latest nf_conntrack_netlink.c 
> > > 
> > > Well, __nf_ct_l4proto_find() being out of line and the way we already
> > > use rcu_read_lock() in this code, it seems following patch is
> > > the most natural way to cope with these lockdep warnings.
> > 
> > I'll take the previous patch to pass it to current -rc. Thanks Hans.
> 
> I'll pass it to net-next, otherwise this will result in one conflict
> with one patch already in net-next if I pass it to net.
>
 
Thanks a lot
/Hans
