From: David Miller <davem@davemloft.net>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 17:10:02 -0700 (PDT)
Message-ID: <20060815.171002.104028951.davem@davemloft.net>
References: <6KfTz-OX-11@gated-at.bofh.it>
	<6KfTA-OX-15@gated-at.bofh.it>
	<E1GD8rX-0001cA-CV@be1.lrz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mitch.a.williams@intel.com,
	notting@redhat.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42221
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750712AbWHPAKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 20:10:01 -0400
To: 7eggert@gmx.de, 7eggert@elstempel.de
In-Reply-To: <E1GD8rX-0001cA-CV@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bodo Eggert <7eggert@elstempel.de>
Date: Wed, 16 Aug 2006 02:02:03 +0200

> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > IMHO idiots who put space's in filenames should be ignored. As long as the
> > bonding code doesn't throw a fatal error, it has every right to return
> > "No such device" to the fool.
> 
> Maybe you should limit device names to eight uppercase characters and up to
> three characters extension, too. NOT! There is no reason to artificially
> impose limitations on device names, so don't do that.

Are you willing to work to add the special case code necessary to
handle whitespace characters in the device name over all of the kernel
code and also all of the userland tools too?

No?  Great, I'm glad that's settled.
