From: netdev-bounce@oss.sgi.com
Subject: (no subject)
Date: Tue, 29 Oct 2002 13:03:08 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029020308.E5A9C12C046@blammo.its.monash.edu.au>
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients: ;
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 22 Oct 2002, Ben Greear wrote:

> No reason not to provide both!  The IOCTL can take care of any drivers
> that don't take module parameters for it, and can do it in a generic
> way.

sure maybe via the ethertool or whatever tool that is being used would
be a good start. The default should still be weight_p.

>
> The tulip driver I am poking at hard-coded it to 16.  64 seems to work
> just as good.
>
> Any idea (other than trial and error) for how to determine a good value
> for this?  Maybe should take the number of active devices into account
> and wiggle things dynamically from user-space?
>

What i recall is 64 was a good number and thats why we had it as default.
I cant remember who changed the value to 16(Robert?), but it does seem to
be a good value as well. If that was the only driver and it had a lot of
packets, it would still get to use all the 300 packets in the budget; it
will just have to do it in 300/16 times ..

cheers,
jamal
