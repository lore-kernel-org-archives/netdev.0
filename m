From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Telnet closing delay
Date: Wed, 2 May 2007 13:19:52 +0400
Message-ID: <20070502091952.GA6060@2ka.mipt.ru>
References: <3C59DB883F7B0B4D8096010D45ACCD1323004D@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38832 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030848AbXEBJUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 05:20:03 -0400
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD1323004D@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 10:48:11PM +0200, Beschorner Daniel (Daniel.Beschorner@facton.com) wrote:
> Since 2.6.21 I often got a 2 seconds delay when closing a telnet session
> to such a machine (even to localhost).
> I was at least not aware of this with older versions, but maybe I'm
> wrong?!?
> Server with delay:
> 
> 0.000095 select(4, [0 3], [], [0], NULL) = 1 (in [3])
> 0.001779 read(3, 0x8059de0, 8192)  = -1 EIO (Input/output error)

Hmm, does not it supposed to stop doing such things on the closed
socket and not enter 10000 select/read loop?
Server behaves incorrectly in this scenario, why and how it can be fixed
is another questions better asked the author.

-- 
	Evgeniy Polyakov
