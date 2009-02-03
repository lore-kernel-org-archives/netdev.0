From: Steve.Glendinning@smsc.com
Subject: Re: Remaining bits for basic support of LDP
Date: Tue, 3 Feb 2009 11:02:31 +0000
Message-ID: <OF4F840E52.4A9545A8-ON80257552.003BBA78-80257552.003CC882@smsc.com>
References: <20090203081042.GA4220@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, Tony Lindgren <tony@atomide.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1501 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752023AbZBCLEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 06:04:08 -0500
In-Reply-To: <20090203081042.GA4220@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 03/02/2009 
08:10:42:
> On Mon, Feb 02, 2009 at 03:57:45PM -0800, Tony Lindgren wrote:
> > * David Miller <davem@davemloft.net> [090202 13:45]:
> > > Well, the SMSC driver is there already in the tree.
> > > 
> > > The only thing not currently being scheduled to hit
> > > 2.6.29-rcX are the recent changes to support platform
> > > specified interrupt flags and all of that stuff.
> > > 
> > > If you want, we can look into pushing that work into
> > > 2.6.29-rcX
> > 
> > That would be great, more platforms to test it on.
> 
> Mainline during the -rc series is not for pushing stuff to get 
additional
> testing.  It's for resolving regressions and fixing bugs, not 
introducing
> changes which could cause regressions and bugs.

Does it help that the smsc911x driver is new this cycle?

Without these patches the driver fails to register its interrupt on many 
arm platforms, so it could be said that these patches do fix regressions 
against the smc911x driver it's intended to replace.

On a related note, if these go in during the next merge window, is there a 
mechanism for ensuring the platform support patches in the set are merged 
after these?

Steve
