From: David Miller <davem@davemloft.net>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Mon, 05 Jul 2010 20:13:24 -0700 (PDT)
Message-ID: <20100705.201324.214230349.davem@davemloft.net>
References: <4C321EAF.9000508@redfish-solutions.com>
	<20100706020734.GA2972@nuttenaction>
	<4C329E15.2000601@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, alex@digriz.org.uk, netdev@vger.kernel.org
To: philipp_subx@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754834Ab0GFDNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 23:13:11 -0400
In-Reply-To: <4C329E15.2000601@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Date: Mon, 05 Jul 2010 21:08:05 -0600

> Yes, most users have admin/privileged rights on their machines, but
> don't know enough to exploit that.

Even "stupid" users are a very slim, marginal, step away from making
use of it once they get shown with a HOWTO on some web site what is
possible with this if QoS is being abided by on their network.

Look, this discussion seems completely pointless.  The behavior is
never changing, setting the TOS will always be non-privileged.

We cannot change the current behavior no matter what political or
other motivation we might have for doing so.  It's been non-privileged
for more than 15 years, and we'd knowingly break applications with the
change.

And I don't even agree with the arguments being proposed for doing
this.  Users can control their packets however they wish.  The only
thing the ISP can do to prevent toying with the TOS bits is putting
logic into your little black box that hooks up to your cable/dsl line.

So this TOS being privileged proposal it's a "no go" from any angle as
far as I'm concerned.
