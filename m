From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 07 Jun 2005 16:05:21 +0900 (JST)
Message-ID: <20050607.160521.73986501.yoshfuji@linux-ipv6.org>
References: <20050607.153359.82068814.yoshfuji@linux-ipv6.org>
	<OF4AE6E385.33144EB9-ON88257019.0024BCE9-88257019.00258FFE@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF4AE6E385.33144EB9-ON88257019.0024BCE9-88257019.00258FFE@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF4AE6E385.33144EB9-ON88257019.0024BCE9-88257019.00258FFE@us.ibm.com> (at Mon, 6 Jun 2005 23:50:16 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > Portable applications do like this:
> 
> > #ifdef IPV6_RECVHOPOPTS
> > // RFC2292bis
> > #else
> > // RFC2292
> > #endif
> 
> > --yoshfuji
> 
> I don't understand. If they do this, they'll
> work already when recompiled (with the patch
> I sent), won't they?

Yes (or they should do so before your favorite distro start shipping with
new constants).

> How does it help to renumber? I can renumber,
> of course-- I just don't see how that does
> anything.

We can still keep old binaries if we renumber.
This is important point.
e.g. people, including myself, can keep using old binaries on new kernels.

--yoshfuji
