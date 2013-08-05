From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] lto, wan/sbni: Make inline assembler symbols visible
 and assembler global
Date: Tue, 6 Aug 2013 01:05:35 +0200
Message-ID: <20130805230535.GP19750@two.firstfloor.org>
References: <1375741094-8166-1-git-send-email-andi@firstfloor.org>
 <20130805.153323.276242626385124232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:45986 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445Ab3HEXFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:05:36 -0400
Content-Disposition: inline
In-Reply-To: <20130805.153323.276242626385124232.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 03:33:23PM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon,  5 Aug 2013 15:18:14 -0700
> 
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > - Inline assembler defining C callable code has to be global
> > - The function has to be visible
> > 
> > Do this in wan/sbni
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> Please just make it use the standard lib/ CRC routines instead.

The problem is I don't have this hardware, and I don't think
I can do such a change without testing it.

FWIW my main interest here is to avoid this thing breaking
my allyesconfig build.

Could you please consider adding it?

If not I'll have to disable the driver in the LTO patchkit.

-Andi
