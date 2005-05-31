From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipv4 ipsec
Date: Tue, 31 May 2005 15:56:42 -0700 (PDT)
Message-ID: <20050531.155642.38710400.davem@davemloft.net>
References: <20050531224717.GE4068@edgar.se.axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: edgar.iglesias@axis.com
In-Reply-To: <20050531224717.GE4068@edgar.se.axis.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Edgar E Iglesias <edgar.iglesias@axis.com>
Date: Wed, 1 Jun 2005 00:47:17 +0200

> Im not sure this is the correct list for ipsec issues, but shouldn't
> the size check at the bottom of net/ipv4/esp4.c be the other way
> around (2.6.11)?

You are right, good catch.  Luckily the size of esp_decap_data
is exactly 20 bytes, so the incorrect test happens to be harmless.

> --- /usr/src/linux-2.6.11-gentoo-r8/net/ipv4/esp4.c     2005-05-11 10:05:03.000000000 +0200
> +++ esp4.c      2005-06-01 00:38:55.000000000 +0200

Please porperly -p1 root your patch so I can apply it, and also
please provide a "Signed-off-by: " line for yourself as well.

It may seem pointless for a one-line patch, but I want to get you
and others into the habit of submitting patches properly in the
future.
