From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Fwd: [Bug 3003] New: might_sleep warning when setting up IPSec
 with IPCOMP]
Date: Fri, 9 Jul 2004 16:58:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709165838.5f7058f0.davem@redhat.com>
References: <20040702143949.21a50b74.akpm@osdl.org>
	<Xine.LNX.4.44.0407090018500.2381-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, niv@us.ibm.com, jmorris@intercode.com.au,
        netdev@oss.sgi.com, christophe@saout.de, mjbligh@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0407090018500.2381-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jul 2004 00:20:56 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> On Fri, 2 Jul 2004, Andrew Morton wrote:
> 
> > Well no.  Those games with deflate_gfp() really need to go away. 
> > in_atomic() works OK if CONFIG_PREEMPT is enabled.  But with
> > CONFIG_PREEMPT=n, in_atomic() returns false inside spinlock.  And
> > in_atomic()'s return value is unaffected by local_irq_disable().
> > 
> > This all needs to be redesigned, sorry.
> 
> Ok, fixed.  Lazy allocation is gone.
> 
> Please apply.

Applied.
