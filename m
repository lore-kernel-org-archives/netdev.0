From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the powerpc
 tree
Date: Sun, 11 Mar 2012 15:56:21 -0700 (PDT)
Message-ID: <20120311.155621.699600599796181447.davem@davemloft.net>
References: <20120309133646.fb8cc30d8c2fd0ef7784d72c@canb.auug.org.au>
	<20120308.221534.712157352097242982.davem@davemloft.net>
	<20120309174416.2b936c5a4a116d56f9a25502@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org,
	paulus@samba.org, linuxppc-dev@lists.ozlabs.org, joe@perches.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab2CKXAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 19:00:38 -0400
In-Reply-To: <20120309174416.2b936c5a4a116d56f9a25502@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 9 Mar 2012 17:44:16 +1100

> On Thu, 08 Mar 2012 22:15:34 -0800 (PST) David Miller <davem@davemloft.net> wrote:
>>
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Fri, 9 Mar 2012 13:36:46 +1100
>> 
>> > Today's linux-next merge of the net-next tree got a conflict in
>> > drivers/net/ethernet/ibm/iseries_veth.c between commit e92a665949f6
>> > ("net: powerpc: remove the legacy iSeries ethernet driver") from the
>> > powerpc tree and commit 41de8d4cff21 ("drivers/net: Remove alloc_etherdev
>> > error messages") from the net-next tree.
>> > 
>> > I just removed the file.
>> 
>> If it makes life easier for anyone I can put the driver removal patch
>> into net-next.
> 
> In this case, I think it will actually help, thanks.  Note that it won;t
> apply cleanly to your tree, but the fixup is easy :-)
> 
> And I discovered that "git am" doesn't like the style of patch I did
> (without the body of the deleted file).  If you just delete
> drivers/net/ethernet/ibm/iseries_veth.c before trying to apply the patch
> it will probably work.

I took care of this the other night.
