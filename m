From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 12:34:09 -0700 (PDT)
Message-ID: <20170407.123409.2077477736939768290.davem@davemloft.net>
References: <20170407190601.GA22991@salvia>
        <1491592185.5800.7.camel@sipsolutions.net>
        <20170407192134.GA23205@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407192134.GA23205@salvia>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Date: Fri, 7 Apr 2017 21:21:34 +0200

> For my usecases in netfilter, the attributes and an specific error
> code should be enough to figure out what is wrong. Will not need
> strings.
> 
> BTW, we may not have an offset, eg. EINVAL because of missing
> attribute. Given we have different requirements, I would leave it to
> each subsystem to decide what netlink error attributes are specified.

Yep, completely agreed.

The use cases for offset and missing attribute I see as follows:

1) Top-level attribute is missing. Here, offset is set to zero
   and the missing attribute number is given as well.

2) Nested attribute is missing.  Offset is set to the location of the
   beginning of nesting, inside of which the missing attribute was
   needed.
