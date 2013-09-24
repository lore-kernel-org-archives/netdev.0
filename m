From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 08:54:24 -0700
Message-ID: <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
	<CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	<20130924.113953.1275344954032811572.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53865 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3IXPyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:54:24 -0400
Received: by mail-ie0-f174.google.com with SMTP id u16so9041542iet.5
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 08:54:24 -0700 (PDT)
In-Reply-To: <20130924.113953.1275344954032811572.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 8:39 AM, David Miller <davem@redhat.com> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 24 Sep 2013 08:22:55 -0700
>
>> We use this value for steering, and could use it for other uses like
>> connection lookup.
>
> For security reasons we absolutely cannot use it for that purpose,
> please stop claiming this.
>
> Any hash function which an attacker can reproduce is attackable.

The Toeplitz function uses a secret key whose length is based on the
input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
attacker can reproduce this if the key is random.  If the problem is
that devices are not being configured with a sufficiently random key
(some actually are using a fixed key :-( ), that's a separate issue
that should be addressed.  It is possible to DoS attack through the
steering mechanism.

Tom
