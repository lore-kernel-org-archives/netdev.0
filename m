From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 14:49:06 -0400 (EDT)
Message-ID: <20130924.144906.781831317299527167.davem@redhat.com>
References: <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
	<20130924.140312.1944338200709799169.davem@redhat.com>
	<1380046245.2736.52.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, David.Laight@aculab.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161Ab3IXStQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 14:49:16 -0400
In-Reply-To: <1380046245.2736.52.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 24 Sep 2013 19:10:45 +0100

> On Tue, 2013-09-24 at 14:03 -0400, David Miller wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Tue, 24 Sep 2013 08:54:24 -0700
>> 
>> > On Tue, Sep 24, 2013 at 8:39 AM, David Miller <davem@redhat.com> wrote:
>> >> From: Tom Herbert <therbert@google.com>
>> >> Date: Tue, 24 Sep 2013 08:22:55 -0700
>> >>
>> >>> We use this value for steering, and could use it for other uses like
>> >>> connection lookup.
>> >>
>> >> For security reasons we absolutely cannot use it for that purpose,
>> >> please stop claiming this.
>> >>
>> >> Any hash function which an attacker can reproduce is attackable.
>> > 
>> > The Toeplitz function uses a secret key whose length is based on the
>> > input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
>> > attacker can reproduce this if the key is random.  If the problem is
>> > that devices are not being configured with a sufficiently random key
>> > (some actually are using a fixed key :-( ), that's a separate issue
>> > that should be addressed.  It is possible to DoS attack through the
>> > steering mechanism.
>> 
>> All of them are using a fixed, defined, key.
> 
> This is certainly false, as I know sfc randomises the key.  And the
> Microsoft RSS spec appears to require that the key is programmable.

Then I stand corrected.
