From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 11:47:04 +0200
Message-ID: <4C1B4098.3090800@grandegger.com>
References: <20100617105201.GA2015@bluebox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: "Hans J. Koch" <hjk@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:36573 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757190Ab0FRJrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 05:47:06 -0400
In-Reply-To: <20100617105201.GA2015@bluebox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hans-J=FCrgen,

On 06/17/2010 12:52 PM, Hans J. Koch wrote:
> This adds a driver for FlexCAN based CAN controllers,
> e.g. found in Freescale i.MX35 SoCs.
>=20
> The original version of this driver was posted by Sascha Hauer in Jul=
y 2009:
> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>=20
> I took this version, added NAPI support, and fixed some problems foun=
d
> during testing. Well, here is the result. Please review.

I briefly browsed the patch and various bits and pieces are missing or
not correctly implemented. Marc already pointed out a few of them:

- I do not find can_put/get_echo_skb functions in the code. How is
  IFF_ECHO supposed to work?

- Support for CAN_CTRLMODE_BERR_REPORTING and do_get_berr_counter()
  seems to be missing.

- Make use of alloc_can_skb() and alloc_can_err_skb().

Wolfgang.
