From: "David S. Miller" <davem@rth.ninka.net>
Subject: Re: [Design] [PATCH] USAGI IPsec
Date: 20 Oct 2002 19:41:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035168066.4817.1.camel@rth.ninka.net>
References: <m3k7kpjt7c.wl@karaba.org>  <3DB41338.3070502@storm.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mitsuru KANDA <mk@linux-ipv6.org>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, cryptoapi-devel@kerneli.org, design@lists.freeswan.org,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Sandy Harris <sandy@storm.ca>
In-Reply-To: <3DB41338.3070502@storm.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Is this code being checked in to the mainline kernel? Or becoming part 
> of the
> CryptoAPI patch set? Bravo, in either case.

We will be incorporating lots of ideas and small code pieces
from USAGI's work, but most of the core engine will be a new
implementation.

A completely new CryptoAPI subsystem has been implemented so that
full lists of page vectors can be passed into the ciphers, which is
necessary for a clean IPSEC implementation.

It is intended that this work will be complete (it isn't done as I
type this) and pushed to Linus upon his return from vacation.
