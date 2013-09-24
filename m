From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 19:10:45 +0100
Message-ID: <1380046245.2736.52.camel@bwh-desktop.uk.level5networks.com>
References: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	 <20130924.113953.1275344954032811572.davem@redhat.com>
	 <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
	 <20130924.140312.1944338200709799169.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <therbert@google.com>, <David.Laight@aculab.com>,
	<netdev@vger.kernel.org>, <jesse.brandeburg@intel.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49779 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208Ab3IXSKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 14:10:49 -0400
In-Reply-To: <20130924.140312.1944338200709799169.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 14:03 -0400, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 24 Sep 2013 08:54:24 -0700
> 
> > On Tue, Sep 24, 2013 at 8:39 AM, David Miller <davem@redhat.com> wrote:
> >> From: Tom Herbert <therbert@google.com>
> >> Date: Tue, 24 Sep 2013 08:22:55 -0700
> >>
> >>> We use this value for steering, and could use it for other uses like
> >>> connection lookup.
> >>
> >> For security reasons we absolutely cannot use it for that purpose,
> >> please stop claiming this.
> >>
> >> Any hash function which an attacker can reproduce is attackable.
> > 
> > The Toeplitz function uses a secret key whose length is based on the
> > input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
> > attacker can reproduce this if the key is random.  If the problem is
> > that devices are not being configured with a sufficiently random key
> > (some actually are using a fixed key :-( ), that's a separate issue
> > that should be addressed.  It is possible to DoS attack through the
> > steering mechanism.
> 
> All of them are using a fixed, defined, key.

This is certainly false, as I know sfc randomises the key.  And the
Microsoft RSS spec appears to require that the key is programmable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
