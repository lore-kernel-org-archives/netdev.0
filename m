From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: how to report network device errors to userspace?
Date: 19 Jun 2002 17:45:55 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <m34rfzq6wb.fsf@trained-monkey.org>
References: <Pine.LNX.4.33.0206191616060.1669-100000@presario> <3D10F552.C05ADD53@nortelnetworks.com> <20020619233659.A7368@wotan.suse.de>
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
   Donald Becker <becker@scyld.com>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: Andi Kleen's message of "Wed, 19 Jun 2002 23:36:59 +0200"
List-Id: netdev.vger.kernel.org

>>>>> "Andi" == Andi Kleen <ak@suse.de> writes:

Andi> On Wed, Jun 19, 2002 at 05:19:14PM -0400, Chris Friesen wrote:
>> Currently the way we are doing it for ethernet is that the
>> userspace app calls a device ioctl() with SIOCGMIIREG multiple
>> times per second, but it would be nice to have the driver notify us
>> asynchronously.

Andi> I would suggest sending a netlink message from the driver.
Andi> That's really what netlink was designed for.

Hmmm, the broader issue here is that we should aim for a generic
interface - if netlink is the way, maybe it would be worth documenting
it and moving towards getting it into more/all drivers.

I have had this question from other sides as well - hadn't thought of
netlink.

Cheers,
Jes
