From: David Miller <davem@davemloft.net>
Subject: Re: [patch] xen-netback: double free on unload
Date: Mon, 24 Jun 2013 01:44:49 -0700 (PDT)
Message-ID: <20130624.014449.788391647881401988.davem@davemloft.net>
References: <20130621062008.GA10873@elgon.mountain>
	<20130624.002607.1816906327683052502.davem@davemloft.net>
	<alpine.DEB.2.02.1306240830580.2215@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, ian.campbell@citrix.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616Ab3FXIou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 04:44:50 -0400
In-Reply-To: <alpine.DEB.2.02.1306240830580.2215@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Mon, 24 Jun 2013 08:31:31 +0100 (BST)

> On Mon, 24 Jun 2013, David Miller wrote:
> 
>> From: Dan Carpenter <dan.carpenter@oracle.com>
>> Date: Fri, 21 Jun 2013 09:20:08 +0300
>>
>> > There is a typo here, "i" vs "j", so we would crash on module_exit().
>> >
>> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>
>> Please always explicitly state the tree for which a patch is
>> applicable.
>>
>> Here I figured it out by trial an error, trying to apply it
>> to 'net' (where it failed) and then 'net-next' (where it
>> applied cleanly).
>>
>> I should never have to play patch monkey games like that, you
>> need to tell me where a patch is targetted.
> 
> Shouldn't one always, by default, work on linux-next?

Bug fixes, especially serious ones, should be targetted at 'net'.
