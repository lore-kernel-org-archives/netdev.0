From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Mon, 4 Jun 2007 22:56:38 -0700
Message-ID: <20070604225638.0577a06a@freepuppy>
References: <200706031237.36773.rjw@sisk.pl>
	<20070604111112.GP4363@elf.ucw.cz>
	<200706041549.11277.rjw@sisk.pl>
	<1180991794.4356.31.camel@nigel.suspend2.net>
	<20070604224146.GE2711@elf.ucw.cz>
	<1180997344.4356.74.camel@nigel.suspend2.net>
	<20070604225303.GG2711@elf.ucw.cz>
	<1180997725.4356.77.camel@nigel.suspend2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>, Peer Chen <peer.chen@uli.com.tw>
To: nigel@nigel.suspend2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49976 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752694AbXFEGIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:08:44 -0400
In-Reply-To: <1180997725.4356.77.camel@nigel.suspend2.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I hope soon to add suspend/resume to the network device class
and remove driver specific suspend/resume from lots of devices.

The class suspend routine would just be:
	pci_save_state
	dev->stop

resume is
	pci_restore_state
	dev->open

for many devices that is all they need.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
