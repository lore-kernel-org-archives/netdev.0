From: Jes Sorensen <jes@trained-monkey.org>
Subject: Re: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: 12 Jun 2003 13:01:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3r85zxmak.fsf@trained-monkey.org>
References: <20030611144249.7cd63c1c.shemminger@osdl.org>
	<m3y90845nu.fsf@trained-monkey.org>
	<20030611.210445.21901735.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030611.210445.21901735.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "David" == David S Miller <davem@redhat.com> writes:

David> How actively are you maintaining acenic. Jes?  :-) This is a
David> very serious question, I haven't seen a 2.5.x change go back to
David> 2.4.x since it's inception.

Hi David,

I clearly haven't been doing the job on acenic recently as I would
have liked nor on 2.5 for that sake, so I don't see all the changes
that just go into 2.5.

David> All this compat nonsense is becoming useless.  Other drivers
David> fair just fine 2.4.x/2.5.x without all this ifdef mumbo-jumbo
David> that litters acenic.c and makes it nearly impossible to read.

Depends on how you look at it. First of all the primary goal of the
macros is not to make it easier to integrate the driver with the
latest state of the art 2.4.x kernel from Marcelo, but rather to make
it possible for people to take the driver and drop it into an earlier
kernel they are running and only upgrade the driver. There have been
quite a lot of acenic users in the past who were not willing to
upgrade their kernels for various reasons and who relied on
this. Putting the compat macros into include/linux/interrupt.h in
Marcelo's tree as you suggested in a later email won't solve this
specific problem.

Nowadays it's probably reasonable to assume that the majority of users
are at 2.4.17+ so I think it's valid to go in and get rid of some of
the compat macros that are there to support kernels older than that.

David> In fact all these localized compat macros make acenic.c HARDER
David> to maintain.

I think we will just have to agree to disagree on this. I find it a
lot easier to read the code when it uses the 2.5 syntax and provides
2.4 compat macros than it is to have a ton of #ifdef's throughout the
code itself.

Cheers,
Jes
