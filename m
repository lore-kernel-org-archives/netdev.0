From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 16 Mar 2015 14:47:46 +0100
Message-ID: <20150316134746.GA6701@salvia>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309135910.GC1528@breakpoint.cc>
 <20150314090035.GA3561@salvia>
 <20150314111325.GG14761@breakpoint.cc>
 <20150316123854.GA5564@salvia>
 <20150316130110.GA1524@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150316130110.GA1524@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 16, 2015 at 02:01:10PM +0100, Florian Westphal wrote:
> We can store ifindexes of physin/physout and re-lookup, sure.
> 
> I'll start on the central storage infrastructure.
> Do you want me to base it on the current patches i have or on plain
> nf-next?

Let me pick these first:

[-next,v2] netfilter: bridge: query conntrack about skb dnat
[-next,resend] netfilter: bridge: remove BRNF_STATE_BRIDGED flag

This, I'll ping David to ack it:

[v2,nf-next,1/6] net: untangle ip_fragment and bridge netfilter

The follow up patches, you please rebase upon the central storage
idea. I like your small state machine idea instead of playing with
flags and the new functions that encapsulate the save/restore mangling
to keep IP/bridge happy.

Thanks.
