From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: Remove state argument from skb_find_text()
Date: Thu, 19 Feb 2015 01:05:59 +0100
Message-ID: <20150219000559.GA28854@salvia>
References: <1424301408-3659-1-git-send-email-prtvar.b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	dan.carpenter@oracle.com
To: Bojan Prtvar <prtvar.b@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424301408-3659-1-git-send-email-prtvar.b@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 19, 2015 at 12:16:48AM +0100, Bojan Prtvar wrote:
> Although it is clear that textsearch state is intentionally passed
> to skb_find_text() as uninitialized argument, it was never used by
> the callers. Therefore, we can simplify skb_find_text() by making it
> local variable.

This infrastructure was conceived to allow keeping the state between
chunk of data, I don't find a good reason to restrict this.
