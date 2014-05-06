From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 09/24] net, diet: Make ethtool optional
Date: Tue, 6 May 2014 05:14:12 +0200
Message-ID: <20140506031412.GN2382@two.firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-10-git-send-email-andi@firstfloor.org>
 <20140505.231140.2172378266544060318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140505.231140.2172378266544060318.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 05, 2014 at 11:11:40PM -0400, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon,  5 May 2014 15:25:58 -0700
> 
> > Small embedded systems don't need ethtool, so make it optional.
> 
> You can't do anything non-trivial with an ethernet device without
> ethtool.

You can configure the IP address and transmit and receive packets,
and that is all a small embedded system is ever interested in.

Remember these systems don't have a shell, they just run a 
single application that only does one thing.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
