From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/3] Fix race conditions in mrf24j40 interrupts
Date: Tue, 08 Oct 2013 15:32:43 -0400 (EDT)
Message-ID: <20131008.153243.1255629541932988146.davem@davemloft.net>
References: <1369188080-8904-1-git-send-email-alan@signal11.us>
	<1381031544-2960-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	david@hauweele.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381031544-2960-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Sat,  5 Oct 2013 23:52:21 -0400

> After testing with the betas of this patchset, it's been rebased and is
> ready for inclusion.
> 
> David Hauweele noticed that the mrf24j40 would hang arbitrarily after some
> period of heavy traffic.  Two race conditions were discovered, and the
> driver was changed to use threaded interrupts, since the enable/disable of
> interrupts in the driver has recently been a lighning rod whenever issues
> arise related to interrupts (costing engineering time), and since threaded
> interrupts are the right way to do it.

Series applied, thanks.
