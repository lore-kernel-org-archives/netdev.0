From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH] LSM: Add inet_sys_snd_skb() LSM hook
Date: Fri, 21 Dec 2007 09:22:55 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0712210918170.27551@us.intercode.com.au>
References: <20071219220539.1626.46073.stgit@flek.americas.hpqcorp.net>
 <20071219222100.1626.38321.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:55381 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765926AbXLTWXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 17:23:04 -0500
In-Reply-To: <20071219222100.1626.38321.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Dec 2007, Paul Moore wrote:

> Add an inet_sys_snd_skb() LSM hook to allow the LSM to provide packet level
> access control for all outbound packets.  Using the existing postroute_last
> netfilter hook turns out to be problematic as it is can be invoked multiple
> times for a single packet, e.g. individual IPsec transforms, adding unwanted
> overhead and complicating the security policy.

I'm fine to ack this from a security pov -- any objections on the 
networking side?


- James
-- 
James Morris
<jmorris@namei.org>
