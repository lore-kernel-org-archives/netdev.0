From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: Re: [PATCH 2.6.33 1/4] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Thu, 4 Feb 2010 15:18:54 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A51@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o143.mxlogic.net ([208.65.144.66]:38558 "EHLO
	p01c11o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758475Ab0BDXTM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 18:19:12 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Miller wrote:
>> This is a resubmission of the Micrel KSZ8841/2 PCI Ethernet driver.
>
> The procfs stuff is a non-starter.
>
> There will undoubtedly be other devices that have switch-like
> facilities that we'd like to export configuration support for.
>
> The last thing we want is a bunch of procfs files that each
> driver decides the layout and behavior of.
>
> We need a centralized way to config such things, and probably
> the best is to have a rtnl_link_ops facility to get at the
> ports and configure them with attribute blobs or similar.
>
> We also said in your first submission that the way you're
> getting at the bridge STP stuff with things like:
>
> +/* Needed for STP support. */
> +#ifdef CONFIG_KSZ8842_STP
> +#include <../net/bridge/br_private.h>
> +#endif
> Yet you left all of this stuff in there.

In my discussions with Alan Cox and Stephen Hemminger, I thought they kind of agree to the code's inclusion in the driver.  Sorry for my misunderstanding.  I will submit another one with those code removed.

P.S. I did not actually receive your response from my company's e-mail server.  I copied it from LKML.
