From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Mon, 08 Mar 2004 13:51:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404CEAD5.9080304@us.ibm.com>
References: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net> <20040308212156.GE26401@wotan.suse.de> <20040308133009.1e068199@dell_ss3.pdx.osdl.net> <20040308213646.GH26401@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040308213646.GH26401@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

>>CONFIG options are of no use vendors who need to ship binary kernels.

But they are real handy to developers and benchmarking
folks who are trying to evaluate their impact and need
to compare with/without :)

> I can well see a vendor trading scalability for experimental non standard TCP 
> algorithms that tend to be disabled anyways.
> 
> Or allocating separately if you prefer that. In theory it may be even
> possible to change the slab cache size at runtime, but that could get tricky.

It would be nice to minimize this if possible, but
keep in mind that dynamic allocation of memory (and freeing
it) is among the costliest performance hits we take..

thanks,
Nivedita
