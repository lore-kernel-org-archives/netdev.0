From: Andi Kleen <ak@suse.de>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 13:33:15 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029133315.5638f842.ak@suse.de>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@napali.hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Oct 2003 22:58:00 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> Also, it appears that current SuSE kernels do indeed have a
> net.core.somaxconn sysctl to let a sysadmin choose a larger SOMAXCONN
> value.

Yes I did that patch some time ago for some server who needed it. If there is interest 
I can submit it  for 2.6. But I'm not sure it fits the "important bug fixes only" rule.

Another alternative would be to make it a fraction of the listen() argument per socket
(e.g. min(tcp_max_syn_backlog,min(128,10%*listenarg))) to allow the application 
to easily change it.

-Andi
