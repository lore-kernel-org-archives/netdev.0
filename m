From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [BK PATCH] 2.4 SCTP updates.
Date: Fri, 27 Feb 2004 14:52:08 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402271435080.13107@localhost.localdomain>
References: <Pine.LNX.4.58.0402271216200.12389@localhost.localdomain>
 <20040227133807.453e8d4b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040227133807.453e8d4b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2004, David S. Miller wrote:

> On Fri, 27 Feb 2004 12:31:18 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> > Thanks for fixing the MSECS_TO_JIFFIES warning.
>
> No problem.  Maybe we want to rename some of those other macros
> to have SCTP_ prefixes too?

Are you referring to JIFFIES_TO_MSECS? Do you see any other macros that need
renaming? I think rest of the macros do have SCTP_ prefix.

As Jeff said, may be we should make them generic?
Is include/linux/time.h a good place?

looking at the other implementations
from net/irda/irda.h
#define MSECS_TO_JIFFIES(ms) (((ms)*HZ+999)/1000)

form include/linux/libata.h
static inline unsigned long msecs_to_jiffies(unsigned long msecs)
{
        return ((HZ * msecs + 999) / 1000);
}

Won't these overflow for large msec values.

Thanks
Sridhar
