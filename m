From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 06:53:17 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805240646380.19084@fbirervta.pbzchgretzou.qr>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>  <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com>  <1211569604.11907.37.camel@perihelion>  <20080523225435.GT20815@postel.suug.ch> <1211603155.11907.79.camel@perihelion>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Graf <tgraf@suug.ch>, Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:47317 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYEXExS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 00:53:18 -0400
In-Reply-To: <1211603155.11907.79.camel@perihelion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2008-05-24 06:25, Jon Masters wrote:
>
>I guess that would also work quite nicely for what I want to do, but the
>problem is that this will require either:
>
>*). The kernel decodes the DMI extension directly.
>*). We can first inform each device which slot it is in (set the slot).
>
>My intention is to implement whatever seems reasonable, and my reason
>for asking is that I am not a networking maintainer, so I want to know
>what seems reasonable :)

Why are we even looking at slot numbers? I do not think there is any
guarantee that the order of slots as a human would recognize them on
the board must always correspond to a monotonically increasing linear
function.
