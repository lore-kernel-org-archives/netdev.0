From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sat, 22 Apr 2006 22:51:10 -0700 (PDT)
Message-ID: <20060422.225110.34182257.davem@davemloft.net>
References: <20060420.120955.28255828.davem@davemloft.net>
	<200604211852.47335.netdev@axxeo.de>
	<20060422114846.GA6629@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@axxeo.de, simlo@phys.au.dk, linux-kernel@vger.kernel.org,
	mingo@elte.hu, netdev@vger.kernel.org, ioe-lkml@rameria.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20187
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751312AbWDWFvL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2006 01:51:11 -0400
To: joern@wohnheim.fh-wedel.de
In-Reply-To: <20060422114846.GA6629@wohnheim.fh-wedel.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: J=F6rn Engel <joern@wohnheim.fh-wedel.de>
Date: Sat, 22 Apr 2006 13:48:46 +0200

> Unless I completely misunderstand something, one of the main points o=
f
> the netchannels if to have *zero* fields written to by both producer
> and consumer.  Receiving and sending a lot can be expected to be the
> common case, so taking a performance hit in this case is hardly a goo=
d
> idea.

That's absolutely correct, this is absolutely critical to
the implementation.

If you're doing any atomic operations, or any write operations by both
consumer and producer to the same cacheline, you've broken things :-)
