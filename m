From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 1 May 2012 03:14:36 -0700
Message-ID: <CAA93jw4sG9EYsM26vm-8cRf5GBGjAL3LDRR7FfPFdN7XT0P0jg@mail.gmail.com>
References: <1335863465.11396.45.camel@edumazet-glaptop>
	<20120501092849.GB3453@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55668 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410Ab2EAKOj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 06:14:39 -0400
Received: by wibhq7 with SMTP id hq7so3669928wib.1
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 03:14:36 -0700 (PDT)
In-Reply-To: <20120501092849.GB3453@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 1, 2012 at 2:28 AM, Hagen Paul Pfeifer <hagen@jauu.net> wro=
te:
> Nice!

Applause as well! While this is something of a fork of this
discussion, I would rather like to resurrect a variant of the old
'time in queue' patch...

http://patchwork.ozlabs.org/patch/125329/

As best as I recall we'd run into trouble with combining things like
netem and complex qdiscs, because we had basically overrun the size of
the control block.

And then there was a long discussion of all that and I forget if any
conclusion was reached.

An alternative to reducing the length of the control block was to find
some way to leverage this sanely in the qdisc layer...

#define HAVE_HW_TIME_STAMP

/**
 * struct skb_shared_hwtstamps - hardware time stamps
 * @hwtstamp:   hardware time stamp transformed into duration
 *              since arbitrary point in time
 * @syststamp:  hwtstamp transformed to system time base
 *


--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
