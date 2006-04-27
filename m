From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 08:17:35 +0200
Message-ID: <200604270817.36041.ak@suse.de>
References: <54AD0F12E08D1541B826BE97C98F99F143AEE0@NT-SJCA-0751.brcm.ad.broadcom.com> <20060426.230812.13989689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, jeff@garzik.org, kelly@au1.ibm.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:4797 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S964958AbWD0GRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 02:17:53 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060426.230812.13989689.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 April 2006 08:08, David S. Miller wrote:

> I'm currently assuming that the protocol processing is still done in
> the kernel on behalf of the user context, so the issues you raise
> really aren't relevant.
> 
> We really shouldn't be jumping the gun so far into the implementation
> as others seem to be doing.  Let's do it simple first and see if
> putting things all the way to userspace even is necessary.

I still have my doubts about doing that securely anyways.
 
> No work is going to get done if we keep carrying on like this
> over details we really do not need to consider right away.

One thing I would like to see is some generic code for the channels.
It might be interesting to try if that data structure could be used
in other parts of the kernel that pass objects around (like VM or block
layer) 

-Andi
