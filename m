From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 01:54:32 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021010.015432.63506989.yoshfuji@linux-ipv6.org>
References: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>
	<20021009170018.H29133@edinburgh.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	usagi@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: dfawcus@cisco.com
In-Reply-To: <20021009170018.H29133@edinburgh.cisco.com>
List-Id: netdev.vger.kernel.org

In article <20021009170018.H29133@edinburgh.cisco.com> (at Wed, 9 Oct 2002 17:00:18 +0100), Derek Fawcus <dfawcus@cisco.com> says:

> All link local's are currently supposed to have those top bits
> ('tween 10 and 64) zero'd,  however any address within the link local
> prefix _is_ on link / connected and should go to the interface.
> 
> i.e. it's perfectly valid for me to assign a link local of fe80:1910::10
>      to an interface and expect it to be work,  likewise for a packet
>      destined to any link local address to trigger ND.

First of all, please don't use such addresses.

By spec, auto-configured link-local address is fe80::/64
and connected route should be /64.

If you do really want to use such addresses (like fe80:1920::10),
you can put another route by yourself, at your own risk.

We should not configure in such way by default.
and, we should even have to add "discard" route for them 
by default for safe.

--yoshfuji
