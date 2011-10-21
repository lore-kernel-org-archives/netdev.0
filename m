From: David Lamparter <equinox@diac24.net>
Subject: Re: [net-next 3/5] igb: Fix for Alt MAC Address feature on 82580 and
 later devices
Date: Fri, 21 Oct 2011 13:11:46 +0200
Message-ID: <20111021111146.GH651279@jupiter.n2.diac24.net>
References: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1319193121-2729-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:34658 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754341Ab1JULL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 07:11:56 -0400
Content-Disposition: inline
In-Reply-To: <1319193121-2729-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2011 at 03:31:59AM -0700, Jeff Kirsher wrote:
> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> In 82580 and later devices, the alternate MAC address feature is
> completely handled by the option ROM and software does not handle
> it anymore.  This patch changes the check_alt_mac_addr function to
> exit immediately if device is 82580 or later.

'Stupid' question: what happens if you put such a card with an x86 
Option ROM into a, say, PowerPC server?

Just feeling like the devil's advocate today :)


-David
