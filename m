From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 18:00:14 +0200
Message-ID: <20130924160014.GA26769@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com> <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com> <20130924.113953.1275344954032811572.davem@redhat.com> <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@redhat.com>,
	David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47989 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439Ab3IXQAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:00:15 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 08:54:24AM -0700, Tom Herbert wrote:
> On Tue, Sep 24, 2013 at 8:39 AM, David Miller <davem@redhat.com> wrote:
> > From: Tom Herbert <therbert@google.com>
> > Date: Tue, 24 Sep 2013 08:22:55 -0700
> >
> >> We use this value for steering, and could use it for other uses like
> >> connection lookup.
> >
> > For security reasons we absolutely cannot use it for that purpose,
> > please stop claiming this.
> >
> > Any hash function which an attacker can reproduce is attackable.
> 
> The Toeplitz function uses a secret key whose length is based on the
> input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
> attacker can reproduce this if the key is random.  If the problem is
> that devices are not being configured with a sufficiently random key
> (some actually are using a fixed key :-( ), that's a separate issue
> that should be addressed.  It is possible to DoS attack through the
> steering mechanism.

I agree, my first comment on the second patch was wrong. I did not assume that
the hashing function does seed itself. We also do not rehash the connection
tables. So if Eric's comments would be addressed its use could be fine.
