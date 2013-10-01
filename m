From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Force SA to be lookup again if SA in
 acquire state
Date: Tue, 1 Oct 2013 13:17:14 +0200
Message-ID: <20131001111714.GL7660@secunet.com>
References: <1379927905-17289-1-git-send-email-fan.du@windriver.com>
 <20130926090301.GC7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36706 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3JALRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:17:17 -0400
Content-Disposition: inline
In-Reply-To: <20130926090301.GC7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 11:03:01AM +0200, Steffen Klassert wrote:
> On Mon, Sep 23, 2013 at 05:18:25PM +0800, Fan Du wrote:
> > If SA is in the process of acquiring, which indicates this SA is more
> > promising and precise than the fall back option, i.e. using wild card
> > source address for searching less suitable SA.
> > 
> > So, here bail out, and try again.
> > 
> > Signed-off-by: Fan Du <fan.du@windriver.com>
> 
> This looks ok, I'll take this into ipsec-next as soon as I can
> update the tree.

Now applied to ipsec-next, thanks!
