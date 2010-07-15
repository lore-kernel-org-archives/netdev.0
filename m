From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] xfrm: cleanup of xfrm_input.c. (resend)
Date: Wed, 14 Jul 2010 22:42:21 -0700 (PDT)
Message-ID: <20100714.224221.226759932.davem@davemloft.net>
References: <AANLkTim7fVRtycf2B07iI7U4chv2NqD267dvunZJYqPj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932443Ab0GOFmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 01:42:08 -0400
In-Reply-To: <AANLkTim7fVRtycf2B07iI7U4chv2NqD267dvunZJYqPj@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 15 Jul 2010 08:21:03 +0300

>  Hi,
>   The patch removes unneeded inclusion of header files
>  (linux/module.h, linux/netdevice.h, net/dst.h and net/ip.h) and adds inclusion
> of linux/skbuff.h instead, in net/xfrm/xfrm_input.c.

Rami, please don't process my feedback like an automaton. :-/

I specifically mentioned linux/skbuff.h because that happened to be
the very first obvious header dependency I found in the xfrm_input.c
file.

There are almost certainly others, and I'd like for you to take the
time to skim over the file and figure out what those might be.

Also, when submitting a new version of a patch, do not hijack the
existing thread.  Instead, make a full fresh submission with a
plain fresh subject line, commit log message, signoff, and patch.
