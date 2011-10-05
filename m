From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] skb fragment API: convert network drivers (part IV)
Date: Wed, 05 Oct 2011 16:13:41 -0400 (EDT)
Message-ID: <20111005.161341.840183744862645286.davem@davemloft.net>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
	<20111005191717.GC30378@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935270Ab1JEUNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:13:51 -0400
In-Reply-To: <20111005191717.GC30378@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@suse.de>
Date: Wed, 5 Oct 2011 12:17:17 -0700

> On Wed, Oct 05, 2011 at 11:28:30AM +0100, Ian Campbell wrote:
>> The following series converts a forth batch of network drivers to the
>> SKB pages fragment API introduced in 131ea6675c76.
>> 
>> There are two drivers/staging patches in here. I'm not sure who normally
>> takes these, I'm sure you guys know though.
> 
> I take them.  As I don't have commit 131ea6675c76 in my tree
> (staging-next), I'd have to wait until that patch gets merged into
> Linus's tree, which should be after 3.2-rc1, right?  Mind if I hold off
> in taking them until then?

We're trying to change all the driver accesses so we can change
the datastructures underneath this stuff.

If we have to wait until after 3.2-rc1, then we won't be able to
make the datastructure change this merge window.
