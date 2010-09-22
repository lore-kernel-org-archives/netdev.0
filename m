From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and
 Bluetooth)
Date: Wed, 22 Sep 2010 14:09:25 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1009221408330.26813@pobox.suse.cz>
References: <1281442367.12579.206.camel@localhost.localdomain> <1281990059-3562-1-git-send-email-alan@signal11.us> <alpine.LNX.2.00.1008231459370.1019@pobox.suse.cz> <alpine.LNX.2.00.1009021724480.26813@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stefan Achatz <erazor_de@users.sourceforge.net>,
	Antonio Ospite <ospite@studenti.unina.it>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Stephane Chatty <chatty@enac.fr>,
	Michael Poole <mdpoole@troilus.org>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>, Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41102 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400Ab0IVMJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Sep 2010 08:09:29 -0400
In-Reply-To: <alpine.LNX.2.00.1009021724480.26813@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Sep 2010, Jiri Kosina wrote:

> > > This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .
> > > 
> > > Alan Ott (2):
> > >   HID: Add Support for Setting and Getting Feature Reports from hidraw
> > >   Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and
> > >     HIDIOCSFEATURE
> > > 
> > >  drivers/hid/hidraw.c          |  105 ++++++++++++++++++++++++++++++++++++--
> > >  drivers/hid/usbhid/hid-core.c |   37 +++++++++++++-
> > >  include/linux/hid.h           |    3 +
> > >  include/linux/hidraw.h        |    3 +
> > >  net/bluetooth/hidp/core.c     |  114 +++++++++++++++++++++++++++++++++++++++--
> > >  net/bluetooth/hidp/hidp.h     |    8 +++
> > >  6 files changed, 260 insertions(+), 10 deletions(-)
> > 
> > Marcel, as per our previous discussion -- what is your word on this? I'd 
> > be glad taking it once you Ack the bluetooth bits (which, as far as I 
> > understood from your last mail, don't have strong objections against any 
> > more).
> 
> ... Marcel?
> 
> I'd really like not to miss 2.6.37 merge window with this.

Seemingly I have not enought powers to get statement from Marcel here 
these days/weeks.

Davem, would you perhaps be able to step in here?

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
