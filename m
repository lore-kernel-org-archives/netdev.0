From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Tue, 05 Jul 2016 13:02:50 -0700
Message-ID: <28421.1467748970@famine>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com> <CAD=hENfHOVBzwrC2Yy371FvxRG9AyJpvAm+s4R6hzU_+o=tJYA@mail.gmail.com> <CAKdSkDX=bf8bNvefjJae2zquEq5+PLDFsfDG--tZrdgzupg5NQ@mail.gmail.com>
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46990 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbcGEUC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 16:02:56 -0400
In-reply-to: <CAKdSkDX=bf8bNvefjJae2zquEq5+PLDFsfDG--tZrdgzupg5NQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
[...]
>I have understood that only miimon is available with 802.3ad:
>
>bonding.txt:
>
>802.3ad:
>...
>        Finally, the 802.3ad mode mandates the use of the MII monitor,
>        therefore, the ARP monitor is not available in this mode.
>
>Is there a way to enable ARP monitor somehow?

	No, there isn't.  ARP monitor is not available in 802.3ad mode.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
