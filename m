From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 1/2] NET: Clone the sk_buff 'iif' field in
 __skb_clone()
Date: Mon, 07 Jan 2008 21:48:46 -0800 (PST)
Message-ID: <20080107.214846.40512910.davem@davemloft.net>
References: <20080107173829.13488.47471.stgit@flek.americas.hpqcorp.net>
	<20080107174741.13488.93482.stgit@flek.americas.hpqcorp.net>
	<Xine.LNX.4.64.0801080810010.15645@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33617
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755628AbYAHFsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:48:47 -0500
In-Reply-To: <Xine.LNX.4.64.0801080810010.15645@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Morris <jmorris@namei.org>
Date: Tue, 8 Jan 2008 08:11:11 +1100 (EST)

> On Mon, 7 Jan 2008, Paul Moore wrote:
> 
> > Both NetLabel and SELinux (other LSMs may grow to use it as well) rely on the
> > 'iif' field to determine the receiving network interface of inbound packets.
> > Unfortunately, at present this field is not preserved across a skb clone
> > operation which can lead to garbage values if the cloned skb is sent back
> > through the network stack.  This patch corrects this problem by properly
> > copying the 'iif' field in __skb_clone() and removing the 'iif' field
> > assignment from skb_act_clone() since it is no longer needed.
> > 
> > Also, while we are here, put the assignments in the same order as the offsets
> > to reduce cacheline bounces.
> > 
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> Dave, perhaps this one should pushed to Linus now as a bugfix?

Probably we should, yes.

Ok, that's what I'll do.
