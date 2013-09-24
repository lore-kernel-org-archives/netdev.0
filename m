From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 12:14:38 -0700
Message-ID: <1380050078.3165.115.camel@edumazet-glaptop>
References: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	 <20130924.113953.1275344954032811572.davem@redhat.com>
	 <CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
	 <20130924.140312.1944338200709799169.davem@redhat.com>
	 <1380046245.2736.52.camel@bwh-desktop.uk.level5networks.com>
	 <CA+mtBx83=X6k42oe4=-hD_coRoX72bJ05Kb5dDfRCDCdTzOH+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@redhat.com>,
	David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:32931 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab3IXTOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 15:14:41 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so4974854pbb.34
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 12:14:40 -0700 (PDT)
In-Reply-To: <CA+mtBx83=X6k42oe4=-hD_coRoX72bJ05Kb5dDfRCDCdTzOH+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 11:24 -0700, Tom Herbert wrote:
> >
> There are some drivers are using fixed keys.  This is not good.  I'll
> take a look at those.  It should be sufficient to randomly set the key
> once at initialization.
> 

If the software fallback (we need this for dumb NIC, or encapsulated
traffic) is more expensive than jhash, I do not think we will ever use
this Toeplitz thing.

We can not use jhash or Toeplitz.
