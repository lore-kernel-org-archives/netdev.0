From: Andi Kleen <ak@suse.de>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 20:44:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309194426.GA12648@wotan.suse.de>
References: <20040309144824.GD14419@suse.de> <20040309150730.GE14419@suse.de> <20040309112529.4c013b9c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040309112529.4c013b9c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 09, 2004 at 11:25:29AM -0800, David S. Miller wrote:
> On Tue, 9 Mar 2004 16:07:30 +0100
> Olaf Kirch <okir@suse.de> wrote:
> 
> > The attached patch disables reporting of multicast and anycast
> > addresses in inet6_dump_ifaddr
> 
> Better to fix /sbin/ip, Andi Kleen posted a patch for that tool
> in a thread on linux-kernel about this very issue.

The patch was buggy unfortunately - it fixed one case, but broke another.
Fixing the root cause like Olaf proposes is better.

-Andi
