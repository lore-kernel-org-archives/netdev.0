From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 13:16:55 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F6433061@orsmsx508.amr.corp.intel.com>
References: <20100830062755.GA22396@verge.net.au>
 <201008311348.55883.arnd@arndb.de>
 <43F901BD926A4E43B106BF17856F0755F6432E3E@orsmsx508.amr.corp.intel.com>
 <201008311943.52955.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:5449 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab0HaURO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 16:17:14 -0400
In-Reply-To: <201008311943.52955.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Arnd Bergmann [mailto:arnd@arndb.de]
>Sent: Tuesday, August 31, 2010 10:44 AM
>To: Rose, Gregory V
>Cc: Ben Pfaff; netdev@vger.kernel.org; Jesse Gross; Stephen Hemminger;
>Chris Wright; Herbert Xu; David Miller
>Subject: Re: [rfc] Merging the Open vSwitch datapath
>
>On Tuesday 31 August 2010, Rose, Gregory V wrote:

[snip]

>
>> No need to implement all of them but there are a small subset of
>> useful rules and associated actions that would be very useful on
>> the embedded switch of an SR-IOV capable NIC.  And these rules
>> and actions would actually promote security from my point of view.
>> I agree that the embedded NIC switch will never (and should never)
>> attempt to implement all the features a full fledged external
>> switch.  But as things stand now embedded NIC switches are so
>> dumb as to be almost useless for most security conscious
>> virtualized applications.  With the implementation of a small
>> set of rules and associated actions we could make them more
>> useful for a number of our customers.
>
>Right. Can you share your specific requirements with the rest of us?
>Maybe start a new email thread with the same people on it, since
>this is now really an Open vSwitch topic.

I'm not quite ready to do that yet.  Disclosure of the specific requirements would be premature at this time because they aren't fully baked yet.  Hopefully we'll get there soon and at that time I will take you up on your suggestion.

>
>> Alright, I'm sort of new to Linux.  Most of my past experience
>> is in the embedded space and is more device oriented so I
>> definitely appreciate getting your perspective on this.
>> Like many folks I just have product features that I need to make
>> available to customers.  Finding a way to do this that is
>> acceptable to the Linux community and promotes the common welfare
>> (so to speak) is all I'm trying to do here.
>
>Ok, cool. Now I think that getting an interface that fits the needs
>of the NIC and Open vSwitch would be great for both Open vSwitch and
>every NIC vendor implementing it, because it means that you can simply
>add a smart NIC and Open vSwitch will run faster without any changes to
>the software setup.

That's the idea!

>Even better for you if you are the first one on the market to implement
>it in hardware ;-)

Yep.  And just getting the eco-system in place is good for everyone.

>
>You should probably take a look at the current ioctl based
>implementation
>in Open vSwitch and figure out if you could make that interface would
>work
>on your NIC, and if not, tell us all what is missing to make that work
>with the new interface.

When the time is right I'll do that.

Again, thanks for your advice!

- Greg

