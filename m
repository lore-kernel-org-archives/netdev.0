From: "David S. Miller" <davem@redhat.com>
Subject: Re: status of ipchains in 2.6?
Date: Tue, 28 Oct 2003 01:50:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028015032.734caf21.davem@redhat.com>
References: <200310280127.h9S1RM5d002140@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.or.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <200310280127.h9S1RM5d002140@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Oct 2003 17:27:22 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> I recently discovered that ipchains is rather broken.  I noticed the
> problem on ia64, but suspect that it's likely to affect all 64-bit
> platforms (if not 32-bit platforms).  A more detailed description of
> the problem I'm seeing is here:
> 
> 	http://tinyurl.com/sm9d
> 
> Unlike ipchains, iptables works perfectly fine, so perhaps we just
> need to update Kconfig to discourage ipchains on ia64 (and/or other
> 64-bit platforms)?

Might want to post this to the netfilter lists or netdev....
Nah, that might actually get the bug fixed.

linux-kernel is always the wrong place to report networking
problems, most networking developers do not read linux-kernel.
They do read netdev@oss.sgi.com so please post things there.
