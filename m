From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Tue, 5 Jun 2007 11:31:29 +0200
Message-ID: <200706051131.30764.rjw@sisk.pl>
References: <200706031237.36773.rjw@sisk.pl> <1180997725.4356.77.camel@nigel.suspend2.net> <20070604225638.0577a06a@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nigel@nigel.suspend2.net, Pavel Machek <pavel@ucw.cz>,
	linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>, Peer Chen <peer.chen@uli.com.tw>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:42814 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761905AbXFEJZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 05:25:54 -0400
In-Reply-To: <20070604225638.0577a06a@freepuppy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 5 June 2007 07:56, Stephen Hemminger wrote:
> I hope soon to add suspend/resume to the network device class
> and remove driver specific suspend/resume from lots of devices.
> 
> The class suspend routine would just be:
> 	pci_save_state
> 	dev->stop
> 
> resume is
> 	pci_restore_state
> 	dev->open
> 
> for many devices that is all they need.

Well, that would be nice, but does it mean there's no need for the $subject
patch?

Rafael


-- 
"Premature optimization is the root of all evil." - Donald Knuth
