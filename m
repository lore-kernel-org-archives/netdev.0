From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Deadlock on ip_mc_list->lock
Date: Tue, 7 Oct 2003 07:54:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007075417.0e2a9173.davem@redhat.com>
References: <20031006140320.GB24082@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20031006140320.GB24082@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Oct 2003 16:03:20 +0200
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

>    Currently this 'return -EINVAL' below is one I suspect from
> being guilty, as it looks to me like that nobody is unlocking
> spinlock & bh in this case, and so system dies horrible death
> after this (saying that userspace scheduled while in_atomic:1).

Patch applied, thanks Petr.
