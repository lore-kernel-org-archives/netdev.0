From: David Miller <davem@davemloft.net>
Subject: Re: Session ID 0 with PPPoE
Date: Sat, 03 Mar 2007 21:07:14 -0800 (PST)
Message-ID: <20070303.210714.07640494.davem@davemloft.net>
References: <20070304023000.GF28150@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mostrows@speakeasy.net
To: florz@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbXCDFHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 00:07:16 -0500
In-Reply-To: <20070304023000.GF28150@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@gmx.de>
Date: Sun, 4 Mar 2007 03:30:00 +0100

> I noticed that the PPPoE code doesn't allow session id 0x0000 to be used
> for an actual session but rather considers 0 a special value denoting
> that the socket is unbound. Now, when reading RFC 2516, I couldn't really
> find anything that would forbid 0x0000 as a session id. Only 0xffff "is
> reserved for future use and MUST NOT be used", while 0x0000 is specified
> as the only allowed value for the session id field on certain types of
> packets, but neither can I find any statement that forbids 0x0000 as
> an ordinary session identifier, nor can I find any reasons that would
> prevent PPPoE from functioning properly with a session id of 0x0000.
> 
> Does anyone of you see any reason why a server would not be allowed to
> select 0x0000 as the session id for a PPPoE session?

I can't, feel free to provide a patch to remove this limitation
if it's important to you.
