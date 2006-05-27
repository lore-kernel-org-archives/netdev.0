From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH v2] bridge: fix locking and memory leak in br_add_bridge
Date: Sat, 27 May 2006 10:58:34 +0200
Message-ID: <20060527105834.64b83809@logostar.upir.cz>
References: <20060525161432.4cbc11ee@griffin.suse.cz>
	<20060525092331.54f14a57@dxpl.pdx.osdl.net>
	<20060526110806.1fa49fe1@griffin.suse.cz>
	<20060526.192611.109883073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:10625 "EHLO cela.cz")
	by vger.kernel.org with ESMTP id S1751219AbWE0I6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 04:58:41 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060526.192611.109883073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, 26 May 2006 19:26:11 -0700 (PDT), David Miller pise:
> From: Jiri Benc <jbenc@suse.cz>
> Date: Fri, 26 May 2006 11:08:06 +0200
> > I don't think this is correct. netdev_run_todo calls dev->destructor
> > which is set to free_netdev by br_dev_setup. So you're calling
> > free_netdev on already freed device.
> 
> Right, we need a more correct version of this bug fix. :)

I think the second version I sent
(http://www.spinics.net/lists/netdev/msg05111.html) should be correct.

 Jiri

-- 
Jiri Benc
SUSE Labs
