From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 09:10:15 -0700
Message-ID: <1380039015.3165.89.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
	 <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	 <20130924.113953.1275344954032811572.davem@redhat.com>
	 <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@redhat.com>,
	David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:62694 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab3IXQKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:10:17 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so5179305pab.22
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:10:17 -0700 (PDT)
In-Reply-To: <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 08:54 -0700, Tom Herbert wrote:

> The Toeplitz function uses a secret key whose length is based on the
> input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
> attacker can reproduce this if the key is random.  If the problem is
> that devices are not being configured with a sufficiently random key
> (some actually are using a fixed key :-( ), that's a separate issue
> that should be addressed.  It is possible to DoS attack through the
> steering mechanism.

Well, your patch would make sense [1] only if we could use hardware
assistance, but right now we have no idea of how safe are the existing
assistances.

[1] Computing Toeplitz in software is way more expensive than jhash.

Dos attack is quite simple right now, even without knowing if the target
uses or not steering.
