From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Mon, 8 Mar 2004 13:45:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308134542.62320cae@dell_ss3.pdx.osdl.net>
References: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net>
	<20040308212156.GE26401@wotan.suse.de>
	<20040308133009.1e068199@dell_ss3.pdx.osdl.net>
	<20040308213646.GH26401@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, linux-net <linux-net@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040308213646.GH26401@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004 22:36:46 +0100
Andi Kleen <ak@suse.de> wrote:

> > CONFIG options are of no use vendors who need to ship binary kernels.
> 
> I can well see a vendor trading scalability for experimental non standard TCP 
> algorithms that tend to be disabled anyways.

If Vegas proves to be as reliable in Linux as BSD, it probably will be the
default.

> Or allocating separately if you prefer that. In theory it may be even
> possible to change the slab cache size at runtime, but that could get tricky.

There is redundancy in the control block now, perhaps that could be squished,
fields that are only used during connection setup or if other things are true.
Also there seems to be several one byte wide booleans that could be collapsed
to bits.

Dave seemed to be against doing everything with CONFIG options. The original Westwood
patch was that way, and he wanted it changed.  Personally, don't care, which
way it ends up.
