From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Mon, 06 Feb 2012 10:15:17 -0500 (EST)
Message-ID: <20120206.101517.1598607878740481170.davem@davemloft.net>
References: <20120203.192933.510206531351047222.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
	<CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregory.v.rose@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =A6tefan Gula <steweg@ynet.sk>
Date: Mon, 6 Feb 2012 09:53:28 +0100

> If I try to request for it, it will eventually fail with a lot of
> records even with filtering...

Then the user can loop increasing the buffer size until the netlink
request succeeds.

It is not a problem.
