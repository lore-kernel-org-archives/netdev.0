From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 13:47:08 -0700
Message-ID: <20070618134708.6be59348@localhost.localdomain>
References: <4676E1DD.1060007@trash.net>
	<20070618130414.35801913@localhost.localdomain>
	<4676E77E.4080707@trash.net>
	<20070618132021.64b08836@localhost.localdomain>
	<4676EE86.5010205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51187 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758413AbXFRUrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:47:42 -0400
In-Reply-To: <4676EE86.5010205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jun 2007 22:43:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > On Mon, 18 Jun 2007 22:13:50 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> > 
> >>Stephen Hemminger wrote:
> >>
> >>>Does this fix it?  It was possible for the PHY interrupt to race
> >>>while bringing link up.
> >>
> >>
> >>No, both problems are still present.
> > 
> > 
> > What hardware. Could you load with messages max: modprobe sky2 debug=15
> 
> sky2 0000:05:00.0: v1.14 addr 0xdb000000 irq 36 Yukon-EC (0xb6) rev 2
> 
> Unloading the driver (with your patch) crashed my box twice.
Was that under load or just idle?

> I've
> attached a log of loading the driver with debug=15, transmitting
> a few packets, then setting it down and up again and trying to
> transmit a few more packets (which didn't work).
> 

What kind of switch.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
