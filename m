From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 13 Jan 2014 20:51:43 -0800
Message-ID: <52D4C25F.8060804@zytor.com>
References: <20140113141824.4301cb76e8e5540d42d74015@canb.auug.org.au>	<20140113142059.f9f1c58c391b2c8bbd05699f@canb.auug.org.au> <20140114140214.7279bcaf88d7a4514d889186@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:43389 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbaANEwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 23:52:36 -0500
In-Reply-To: <20140114140214.7279bcaf88d7a4514d889186@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2014 07:02 PM, Stephen Rothwell wrote:
> Hi all,
> 
> On Mon, 13 Jan 2014 14:20:59 +1100 Stephen Rothwell
> <sfr@canb.auug.org.au> wrote:
>> 
>> On Mon, 13 Jan 2014 14:18:24 +1100 Stephen Rothwell
>> <sfr@canb.auug.org.au> wrote:
>>> 
>>> Today's linux-next merge of the tip tree got conflicts in 
>>> arch/arc/include/asm/Kbuild, arch/cris/include/asm/Kbuild, 
>>> arch/hexagon/include/asm/Kbuild,
>>> arch/microblaze/include/asm/Kbuild, 
>>> arch/parisc/include/asm/Kbuild and
>>> arch/score/include/asm/Kbuild between commit e3fec2f74f7f
>>> ("lib: Add missing arch generic-y entries for 
>>> asm-generic/hash.h") from the net-next tree and commit
>>> 93ea02bb8435 ("arch: Clean up asm/barrier.h implementations
>>> using asm-generic/barrier.h") from the tip tree.
>>> 
>>> I fixed it up (see below) and can carry the fix as necessary
>>> (no action is required).
>>> 
>>> BTW: thanks for not keeping the Kbuild files sorted :-(
>> 
>> I missed arch/mn10300/include/asm/Kbuild the first time round.
> 
> And ... git rerere does not work well here.  It stores resolutions
> by a hash of the (sanitised) conflict and since most of these files
> have exactly the same conflict, I am going to have to edit 5 of
> them by hand every day.
> 

Well, you probably can keep a diff from the conflict-merge tree to the
fix, but still.

Is there a sensible way we can fix this in either net-next or tip?

	-hpa
