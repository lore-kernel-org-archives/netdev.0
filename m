From: David Miller <davem@davemloft.net>
Subject: Re: x25: possible skb leak on bad facilities
Date: Mon, 07 Feb 2011 13:42:40 -0800 (PST)
Message-ID: <20110207.134240.260080815.davem@davemloft.net>
References: <20110206.202824.260090071.davem@davemloft.net>
	<AANLkTik8hg5G2FYDCoRgh72v-_euGWKix9Fxm89UdXie@mail.gmail.com>
	<1297073295.9577.13.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, john@calva.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tim.gardner@canonical.com
To: andrew.hendry@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297073295.9577.13.camel@jaunty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Mon, 07 Feb 2011 21:08:15 +1100

> 
> Originally x25_parse_facilities returned
> -1 for an error
>  0 meaning 0 length facilities
>>0 the length of the facilities parsed.
> 
> 5ef41308f94dc introduced more error checking in x25_parse_facilities
> however used 0 to indicate bad parsing
> a6331d6f9a429 followed this further for DTE facilities, again using 0 for bad parsing.
> 
> The meaning of 0 got confused in the callers.
> If the facilities are messed up we can't determine where the data starts.
> So patch makes all parsing errors return -1 and ensures callers close and don't use the skb further.
> 
> Reported-by: Andy Whitcroft <apw@canonical.com>
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Please reference the commit header line text when referring to SHA1
IDs, because when backporting to other GIT trees the SHA1 IDs might be
different.

I took care of this when applying your patch, thanks.
