From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 11/11] asmlinkage, wan/sbni: Make inline assembler
 symbols visible and assembler global
Date: Wed, 23 Oct 2013 04:09:55 +0200
Message-ID: <20131023020955.GF29695@two.firstfloor.org>
References: <1382458346-24811-1-git-send-email-andi@firstfloor.org>
 <1382458346-24811-12-git-send-email-andi@firstfloor.org>
 <20131022.135928.2040131908206663695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, ak@linux.intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131022.135928.2040131908206663695.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 22, 2013 at 01:59:28PM -0400, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 22 Oct 2013 09:12:26 -0700
> 
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > - Inline assembler defining C callable code has to be global
> > - The function has to be visible
> > 
> > Do this in wan/sbni
> > 
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> Is it really impossible to use the generic crc32 support instead of this
> unsightly custom inline assembler?

Yes it's impossible.

There's no way for me to test it, and this would be a far too big change
to submit untested.

Also my only interest here is this thing not breaking my LTO
allyesconfig build. I'm not even sure what it does.

Just because some legacy driver breaks my build you cannot make me
accountable for maintaining it now. 

If it's not possible to get this trivial change in I would need
to mark it "depends on !LTO" in Kconfig.

-Andi
