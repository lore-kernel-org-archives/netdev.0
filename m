From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 14:03:12 -0400 (EDT)
Message-ID: <20130924.140312.1944338200709799169.davem@redhat.com>
References: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	<20130924.113953.1275344954032811572.davem@redhat.com>
	<CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649Ab3IXSDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 14:03:25 -0400
In-Reply-To: <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 24 Sep 2013 08:54:24 -0700

> On Tue, Sep 24, 2013 at 8:39 AM, David Miller <davem@redhat.com> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Tue, 24 Sep 2013 08:22:55 -0700
>>
>>> We use this value for steering, and could use it for other uses like
>>> connection lookup.
>>
>> For security reasons we absolutely cannot use it for that purpose,
>> please stop claiming this.
>>
>> Any hash function which an attacker can reproduce is attackable.
> 
> The Toeplitz function uses a secret key whose length is based on the
> input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
> attacker can reproduce this if the key is random.  If the problem is
> that devices are not being configured with a sufficiently random key
> (some actually are using a fixed key :-( ), that's a separate issue
> that should be addressed.  It is possible to DoS attack through the
> steering mechanism.

All of them are using a fixed, defined, key.
