From: Andi Kleen <ak@suse.de>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 20:47:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029204707.67f9a2e1.ak@suse.de>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
	<20031029105809.0a1f27a1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031029105809.0a1f27a1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Oct 2003 10:58:09 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 28 Oct 2003 22:58:00 -0800
> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> 
> > You obviously want some control over how big the listen queue can
> > grow, but it seems to me that a sysctl would be in place.  I found
> > this patch to do that, but no reaction to it:
> > 
> >   http://www.ussg.iu.edu/hypermail/linux/kernel/0205.0/1287.html
> 
> I think I'm going to apply this patch.
> 
> People can then set the limit to what they want, the default
> stays at 128, and the SOMAXCONN define itself does not change.
> 
> Ok David?

Can I respectfully ask to name the sysctl net/core/somaxconn  ? 

That is the name used in the SuSE/UL kernels and has been shipping for some time
and already has a big user base, and there is no reason to break compatibility
for them.

Thanks,

-Andi
