From: "David S. Miller" <davem@redhat.com>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 10:58:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029105809.0a1f27a1.davem@redhat.com>
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

> You obviously want some control over how big the listen queue can
> grow, but it seems to me that a sysctl would be in place.  I found
> this patch to do that, but no reaction to it:
> 
>   http://www.ussg.iu.edu/hypermail/linux/kernel/0205.0/1287.html

I think I'm going to apply this patch.

People can then set the limit to what they want, the default
stays at 128, and the SOMAXCONN define itself does not change.

Ok David?
