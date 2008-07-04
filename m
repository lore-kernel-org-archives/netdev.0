From: Brad Campbell <brad@wasp.net.au>
Subject: Re: 2.6.28-rc8-git3 forcedeth WARNING (kills the interface)
Date: Fri, 04 Jul 2008 22:59:19 +0400
Message-ID: <486E7307.8040809@wasp.net.au>
References: <486CA4EB.1040804@wasp.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wasp.net.au ([203.190.192.17]:38649 "EHLO wasp.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbYGDS7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 14:59:25 -0400
In-Reply-To: <486CA4EB.1040804@wasp.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brad Campbell wrote:
> G'day all,
> Same problem I reported in -rc7.
> 
> This is a vanilla kernel with the addition of the imq and adt7475 
> modules. imq is not relevant here as I only added it this morning and 
> this has been going on all week.
> 

I've tested without the adt7475 and i2c-nForce2 module today after a clean boot. No Difference.

On advice recompiled with CONFIG_FORCEDETH_NAPI disabled and "modprobe forcedeth msi=0 msix=0". It 
died within 5 minutes with the same symptoms. Is there anything else anyone can recommend to test?

Brad
-- 
Dolphins are so intelligent that within a few weeks they can
train Americans to stand at the edge of the pool and throw them
fish.
