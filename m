From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 16:23:21 -0700
Message-ID: <20060815162321.03eaa2ee@localhost.localdomain>
References: <20060815214914.GA5307@nostromo.devel.redhat.com>
	<Pine.CYG.4.58.0608151532070.2316@mawilli1-desk2.amr.corp.intel.com>
	<20060815154444.286e12ed@localhost.localdomain>
	<20060815.155612.111203542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, notting@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23759 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750809AbWHOX1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 19:27:32 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060815.155612.111203542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 15:56:12 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 15 Aug 2006 15:44:44 -0700
> 
> > IMHO idiots who put space's in filenames should be ignored. As long
> > as the bonding code doesn't throw a fatal error, it has every right
> > to return "No such device" to the fool.
> 
> I agree that whitespace in device names push the limits of sanity.
> 
> But if we believe that, we should enforce it in dev_valid_name().
> 
> Does anyone really mind if I add the whitespace check there?

That is a good idea since it protects other interfaces from possible problems.
