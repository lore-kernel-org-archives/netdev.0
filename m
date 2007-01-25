From: "JUNG, Christian" <christian.jung@saarstahl.com>
Subject: RE: bonding: bug in balance-alb mode (incorrect update-ARP-replie
	s)
Date: Thu, 25 Jan 2007 15:41:32 +0100
Message-ID: <FA8270F9F8D35946ADDBC0F36E6667CE0175C9BE@nts27.saarstahl.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: 'Jay Vosburgh' <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sag2.saarstahl.de ([62.154.234.163]:2593 "HELO
	ig01.int.saarstahl.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S965031AbXAYOlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 09:41:37 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Jay Vosburgh <fubar@us.ibm.com> wrote:
> 
> 	Is your test occuring on an isolated network, and is there other
> concurrent network traffic that might be affecting things?

The problem still persists as long as the box is connected to our Ciscos.

I tried to simulate it with a dumb switch with my two boxes connected only.
But there were no unsolicited ARP-replies anymore.

On the Ciscos I sometimes see ARP-replies with a destination MAC of
00:00:00:00:00:00 (!) from some Linux-boxes which are using bonding.
Currently I don't have a clue from where they're coming...

The boxes are receiving around 200 ARP-replies a minute - so yes, there's
concurrent network traffic :-)
