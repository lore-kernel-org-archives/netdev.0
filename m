From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Mon, 8 Mar 2004 22:36:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308213646.GH26401@wotan.suse.de>
References: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net> <20040308212156.GE26401@wotan.suse.de> <20040308133009.1e068199@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, linux-net <linux-net@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040308133009.1e068199@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> CONFIG options are of no use vendors who need to ship binary kernels.

I can well see a vendor trading scalability for experimental non standard TCP 
algorithms that tend to be disabled anyways.

Or allocating separately if you prefer that. In theory it may be even
possible to change the slab cache size at runtime, but that could get tricky.

-Andi
