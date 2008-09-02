From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND 2.6.27] netlink: Remove compat API for nested
 attributes
Date: Tue, 02 Sep 2008 16:04:03 -0700 (PDT)
Message-ID: <20080902.160403.83966810.davem@davemloft.net>
References: <20080828140050.GB20815@postel.suug.ch>
	<20080828140527.GC20815@postel.suug.ch>
	<48BDB434.1040805@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38061
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753046AbYIBXEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 19:04:10 -0400
In-Reply-To: <48BDB434.1040805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 02 Sep 2008 14:46:28 -0700

> Thomas Graf wrote:
> > Removes all _nested_compat() functions from the API. The prio qdisc
> > no longer requires them and netem has its own format anyway. Their
> > existance is only confusing.
> > Resend: Also remove the wrapper macro.
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> I don't think we need to do anything as drastic as completely throwing out this part of the Kernel ABI.  This is what I have been trying to get at all along.  All we need to do is revert the two patches that we talked about earlier and everything goes back to working.

He's removing it because in 2.6.27 and later, besides netem, there are no
other users.  And we don't want to encourage new uses of this thing.

And all of that, I agree with.
