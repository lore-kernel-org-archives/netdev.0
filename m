From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] via-rhine: hardware VLAN support
Date: Sun, 21 Nov 2010 14:17:57 +0100
Message-ID: <20101121131756.GA18509@core.hellgate.ch>
References: <20101105104303.GA8325@core.hellgate.ch>
 <AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
 <20101108162132.GA32728@core.hellgate.ch>
 <AANLkTim40QH2AWz8YtW_y3=WjEU0_Rom9-CPFj-O5MCt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail11.bluewin.ch ([195.186.18.61]:19939 "EHLO
	mail11.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083Ab0KUNSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 08:18:01 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTim40QH2AWz8YtW_y3=WjEU0_Rom9-CPFj-O5MCt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Nov 2010 12:53:57 -0800, Jesse Gross wrote:
> On Mon, Nov 8, 2010 at 8:21 AM, Roger Luethi <rl@hellgate.ch> wrote:
> > On Fri, 05 Nov 2010 11:31:56 -0700, Jesse Gross wrote:
> > Can you point me to a driver that has been switched to use the new methods
> > already? Is there some other form of documentation?
> 
> bnx2 is an example of a driver that has been converted.  The commit
> that actually made the change was
> 7d0fd2117e3d0550d7987b3aff2bfbc0244cf7c6, which should highlight the
> differences.  A key point is that drivers should no longer reference
> vlan groups at all.

bnx2 does not support hardware VLAN filters, but ixgbe does (converted by
commit f62bbb5e62c6e4a91fb222d22bc46e8d4d7e59ef). ixgbe keeps a list of
configured VLANs in a device private data structure (active_vlans). Is that
the model to follow?

