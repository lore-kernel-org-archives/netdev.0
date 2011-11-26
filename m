From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net/stable] gro: reset vlan_tci on reuse
Date: Sat, 26 Nov 2011 07:52:02 -0800
Message-ID: <20111126155202.GA8467@kroah.com>
References: <1322320749-8055-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:44020 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752620Ab1KZPwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 10:52:37 -0500
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 4131720C66
	for <netdev@vger.kernel.org>; Sat, 26 Nov 2011 10:52:37 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <1322320749-8055-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 10:19:09AM -0500, Benjamin Poirier wrote:
> This one liner is part of upstream
> commit 3701e51382a026cba10c60b03efabe534fba4ca4
> 
> and it is in the same vein as
> commit 66c46d741e2e60f0e8b625b80edb0ab820c46d7a
> commit 6d152e23ad1a7a5b40fef1f42e017d66e6115159
> 
> which are already in -stable.
> 
> For drivers using the vlan_gro_frags() interface, a packet with invalid tci
> leads to GRO_DROP and napi_reuse_skb(). The skb has to be sanitized before
> being reused or we'll send skb's with invalid vlan_tci up the stack where
> they're not expected.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> Cc: Jesse Gross <jesse@nicira.com>
> 
> ---
> 
> Please note, reusing skb's with an invalid vlan_tci can cause panics on
> 2.6.32.y -stable kernels.

You forgot to mention what stable kernel tree(s) you want this patch
applied to.  And why can't I just take all of
3701e51382a026cba10c60b03efabe534fba4ca4? (hint, when refering to git
commit ids, please put the description of what they are in () after them
so we have a hint and don't have to dig through a git tree to find
them.)

Also, I need David's ack before I can take this, or any other network
patch, for the stable tree.

thanks,

greg k-h
