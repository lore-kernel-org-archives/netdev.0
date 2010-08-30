From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 11:45:19 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
 <20100830183328.GI7629@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56030 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab0H3Spa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 14:45:30 -0400
In-Reply-To: <20100830183328.GI7629@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Ben Pfaff [mailto:blp@nicira.com]
>Sent: Monday, August 30, 2010 11:33 AM
>To: Rose, Gregory V
>Cc: netdev@vger.kernel.org; Jesse Gross; Stephen Hemminger; Chris
>Wright; Herbert Xu; Arnd Bergmann; David Miller
>Subject: Re: [rfc] Merging the Open vSwitch datapath
>
>[restoring CCs that I inadvertently busted upthread]
>
>On Mon, Aug 30, 2010 at 11:26:17AM -0700, Rose, Gregory V wrote:
>> >From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org]
>> >On Behalf Of Ben Pfaff
>> >
>> >Simon Horman <horms@verge.net.au> writes:
>> >
>> >>    * Possible use of netlink for user-space interface
>> >
>> >I'm working on this one this week, for what it's worth.
>>
>> I just want to put in a plug for the netlink interface.  For NICs with
>> EVB we'll need it.
>
>Off-hand, the main reasons to use Netlink, instead of the existing
>character device interface, are that Netlink is easier to extend and
>that it should reduce or eliminate the 32-to-64 bit compat layer
>currently in the Open vSwitch tree.
>
>Why will NICs with EVB require Netlink for the Open vSwitch interface?

As of now there are no existing ways to get switch configuration to a NIC without resorting to a customized interface such as a private IOCTL.  EVB is an emerging standard that I think would be desirable to support in the kernel.  As you mention netlink is easier to extend and I think it would be a great way to add support for NIC EVB in the kernel.  But even with a kernel interface there is still no user level tool.

>From what I can tell the Open vSwitch interface with its ability to set packet forwarding rules is also a good candidate for a user space tool to set rules for EVB capable NICs.  Seems like a natural extension to me.

- Greg

