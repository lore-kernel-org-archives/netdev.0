From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/7] netfilter: nf_ct_helper: better logging for dropped
 packets
Date: Mon, 18 Feb 2013 17:23:37 -0800
Message-ID: <1361237017.2046.9.camel@joe-AO722>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
	 <1361232651-5626-8-git-send-email-pablo@netfilter.org>
	 <1361233322.2046.3.camel@joe-AO722> <20130219011109.GA6362@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130219011109.GA6362@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-19 at 02:11 +0100, Pablo Neira Ayuso wrote:
> On Mon, Feb 18, 2013 at 04:22:02PM -0800, Joe Perches wrote:
> > On Tue, 2013-02-19 at 01:10 +0100, pablo@netfilter.org wrote:
> > > This patch modifies the existing code to provide more specific
> > > error message in the scope of each helper to help users to debug
> > > the reason why the packet has been dropped, ie:
> > []
> > > diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
> > []
[]
> > do please try to avoid splitting formats
> > 
> > 				nf_ct_helper_log(skb, ct,
> > 						 "cannot add expectation");
> 
> Done whenever possible, sometimes I see myself forced to split them to
> fit 80-chars per column.

It's always possible.

Just ignore line length limitations for formats.

If the formats are on a separate line, checkpatch
won't complain either.

If nf_cg_helper_log was named nf_cg_helper_printk
checkpatch wouldn't complain if the original line
with format was > 80 cols

		nf_ct_helper_printk(skb, ct, "some really long format past 80 cols ...");

but then the log isn't really a printk either and
that's a checkpatch limitation on understanding
what is and isn't a logging output function.

