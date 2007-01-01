From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/flow.c: compare data with memcmp
Date: Mon, 01 Jan 2007 00:49:05 -0800 (PST)
Message-ID: <20070101.004905.98552337.davem@davemloft.net>
References: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
	<20061231.123715.115911390.davem@davemloft.net>
	<80ec54e90612312347w2b906e5eg725a7761110c6897@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40338
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933258AbXAAItH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jan 2007 03:49:07 -0500
To: daniel.marjamaki@gmail.com
In-Reply-To: <80ec54e90612312347w2b906e5eg725a7761110c6897@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Daniel_Marjam=E4ki" <daniel.marjamaki@gmail.com>
Date: Mon, 1 Jan 2007 08:47:48 +0100

> So you mean that in this particular case it's faster with a handcoded
> comparison than memcmp? Because both key1 and key2 are located at
> word-aligned addresses?
> That's fascinating.

Essentially, yes.

However, I wonder.  GCC should be able to see this also, and
if it expands the memset() inline the code emitted should be
very similar.

It is something to investigate on a few cpu types, for sure.
