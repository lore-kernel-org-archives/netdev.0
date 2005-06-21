From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 00:34:36 +0200
Message-ID: <20050621223436.GG14251@wotan.suse.de>
References: <p73oe9zbcx0.fsf@verdi.suse.de> <Pine.LNX.4.44.0506211507110.21812-100000@bluewest.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Rick Jones <rick.jones2@hp.com>,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0506211507110.21812-100000@bluewest.scyld.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> While much has changed since then, the same basic parameters remain
>    - cache line size

In 96 we had 32 byte cache lines. These days 64-128 are common,
with some 256 byte cache line systems around.

>    - frame header size (MAC+IP+ProtocolHeader)

In 96 people tended to not use time stamps.

>    - hot cache lines from copying or type classification

Not sure what you mean with that.

>    - cold memory lines from PCI writes

I suspect in '96 chipsets also didn't do as aggressive prefetching
as they do today.

-Andi
