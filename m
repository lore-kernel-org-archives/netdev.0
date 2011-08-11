From: Alan Cox <alan@linux.intel.com>
Subject: Re: [net-next 02/10] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Thu, 11 Aug 2011 10:02:55 +0100
Message-ID: <20110811100255.421a5fbc@bob.linux.org.uk>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1313033278-7337-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@tredhat.com,
	sassmann@redhat.com,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	David Hinds <dahinds@users.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26165 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612Ab1HKI7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 04:59:13 -0400
In-Reply-To: <1313033278-7337-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Aug 2011 20:27:50 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> Moves the 3Com drivers into drivers/net/ethernet/3com/ and the
> necessary Kconfig and Makefile changes.

This seems to be repeating one of the problems of the last one

> drivers/net/{ => ethernet/3com}/acenic.c         |    0
> drivers/net/{ => ethernet/3com}/acenic.h         |    0

Acenic was not 3com. It was a wide variety of vendors including 3Com who
rebadged it.

Alan
