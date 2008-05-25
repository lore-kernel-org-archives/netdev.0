From: David Miller <davem@davemloft.net>
Subject: Re: network interface *name* alias support?
Date: Sun, 25 May 2008 05:17:13 -0700 (PDT)
Message-ID: <20080525.051713.124717485.davem@davemloft.net>
References: <48387B18.2090300@trash.net>
	<alpine.LNX.1.10.0805242254020.19084@fbirervta.pbzchgretzou.qr>
	<4838D7E4.7050401@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, dwmw2@infradead.org, jchapman@katalix.com,
	Matt_Domsch@dell.com, jonathan@jonmasters.org, tgraf@suug.ch,
	rick.jones2@hp.com, auke-jan.h.kok@intel.com,
	johnathan@jonmasters.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44222
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760194AbYEYMRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 08:17:18 -0400
In-Reply-To: <4838D7E4.7050401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 25 May 2008 05:07:16 +0200

> Jan Engelhardt wrote:
> > On Saturday 2008-05-24 22:31, Patrick McHardy wrote:
> >> David Woodhouse wrote:
> >>> On Sat, 2008-05-24 at 10:15 +0100, James Chapman wrote:
> >>>> Wouldn't it be better to fix any applications that can't handle
> >>>> renamed devices?
> >>> _Are_ there any such applications? Other than NetworkManager crapping
> >>> itself when the device name is too long, I'm not aware of any.
> >> iptraf uses device names to determine the device type:
> > 
> > Run `iptraf -u`, and it works with any name.
> 
> Thanks for the hint. Its stupid nevertheless.

I think it's stupid too.

Physical geography information for a device is available
to userspace already.  If tools want to present that to
the user in a suitable interface, fine.  But what is
being proposed here is not necessary to implement that.
