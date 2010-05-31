From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Tue, 1 Jun 2010 01:19:06 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1006010115030.1536@localhost>
References: <alpine.LNX.2.00.1005311905520.469@nippy.intranet> <AANLkTilkooBglbk33yDHmk8c_ZdlamOW8FVvuvjQaNsF@mail.gmail.com> <1275318493.6503.206.camel@Joe-Laptop.home> <20100531.081412.27799681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, geert@linux-m68k.org, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20100531.081412.27799681.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 31 May 2010, David Miller wrote:

> From: Joe Perches <joe@perches.com>
> Date: Mon, 31 May 2010 08:08:13 -0700
> 
> > There are many uses of KERN_DEBUG that are reasonable to have always 
> > enabled.
> 
> Doubtful.
> 
> pr_debug() makes a ton of sense as currently implemented. It's for 
> messages that we want both compile time and run-time control over.
> 
> The case we have here in mac8390 seems like it should stay as pr_info().  
> Because 1) it's already controlled by a run-time knob so controlling it 
> even further is confusing and 2) the message is "informative", it lets 
> the user know a feature cannot be enabled, thus pr_info().

If that is true in general, then ei_debug itself becomes questionable.

In the case of mac8390 at least, I'm certainly leaning toward changing the 
pr_info (conditional on ei_debug) to pr_debug (unconditional).

Finn
