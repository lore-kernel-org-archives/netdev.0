From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 19:42:35 -0500
Message-ID: <CAOwfj2M6p55s6exrW1y55tddzHd1PvBOW6RpWfFK2hTjmYi=hA@mail.gmail.com>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	<1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
	<1394578747.28839.4.camel@joe-AO722>
	<CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
	<1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
	<1394663197.3915.61.camel@joe-AO722>
	<1394670528.20857.10.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Perches <joe@perches.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394670528.20857.10.camel@deadeye.wl.decadent.org.uk>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 7:28 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Wed, 2014-03-12 at 15:26 -0700, Joe Perches wrote:
>> On Wed, 2014-03-12 at 21:14 +0000, Ben Hutchings wrote:
>> > These look like the statistic names specified in IEEE 802.3.  I would
>> > support a general move to using standard names for MAC stats in Ethernet
>> > drivers, because they are quite clearly defined and widely implemented
>> > in hardware.  However, that is not the current practice in most Linux
>> > drivers.
>>
>> Hey Ben.
>>
>> Maybe something like this would be a start?
>>
>> Change the actual #defines/strings to taste.
>>
>> Maybe this shouldn't be in uapi or maybe in if_ether.h
> [...]
>
> This is pointless without also nailing down the definition of each
> statistic.  That could be done with reference to standards/RFCs, of
> course.

As I was working through the V4 patch and looking at the names used by
other drivers, it occurred to me it would be useful to create a set of
standard definitions that referenced the relevant IEEE Specification
and RFC. I'm willing to take that on for this submission by adding
those to the driver documentation. I think that would be useful to
users and could then be moved to a "standard definitions" text file
that other drivers could reference.

Joe had a few more comments I'd like to address (thanks Joe), I could
pick this up as part of a V5 submission if you agree, or if you have a
different suggestion I could possibly take that on as well.

>
> Ben.
>
> --
> Ben Hutchings
> Experience is directly proportional to the value of equipment destroyed.
>                                                          - Carolyn Scheppner

All the best,

Vince
