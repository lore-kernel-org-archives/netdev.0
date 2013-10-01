From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Tue, 1 Oct 2013 07:15:43 +0200
Message-ID: <20131001051543.GF7660@secunet.com>
References: <CALnjE+ofaXQa3gsPPxqdWZeBxgML6M1vnC9mmc5dufwy0gJO-Q@mail.gmail.com>
 <20130927074530.GD7660@secunet.com>
 <CALnjE+pkaAwiSp_S=TE70L+QvyZr1TzEC48Dnz9+8Hy3fbnOyQ@mail.gmail.com>
 <20130930.144026.652414415839724107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55009 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab3JAFPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 01:15:47 -0400
Content-Disposition: inline
In-Reply-To: <20130930.144026.652414415839724107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 30, 2013 at 02:40:26PM -0400, David Miller wrote:
> 
> Steffen can you respin these patches and make sure to:
> 
> 1) Add reference to SHA1_ID and commit header line of commit
>    introducing this bug, as Eric requested, in this format:
> 
> 	$SHA1_ID ("Commit header line text.")

Sure, will do that.

> 
> 2) __skb_push() --> skb_push()
> 

I'll do an additional patch for this, as it was not introduced
with the same commit as the memory corruption I've fixed here.

I'll also add a patch to fix the double unregister of the fallback
device that was introduced with commit 6c742e714d8
("ipip: add x-netns support").
