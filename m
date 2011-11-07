From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Mon, 7 Nov 2011 23:02:20 +0100
Message-ID: <20111107220220.GD1833899@jupiter.n2.diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320512055-1231037-2-git-send-email-equinox@diac24.net>
 <20111107134142.05d997a5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:39894 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab1KGWCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 17:02:30 -0500
Content-Disposition: inline
In-Reply-To: <20111107134142.05d997a5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 01:41:42PM -0800, Stephen Hemminger wrote:
> On Sat,  5 Nov 2011 17:54:14 +0100
> David Lamparter <equinox@diac24.net> wrote:
> 
> > - *	@h_vlan_proto: ethernet protocol (always 0x8100)
> > + *	@h_vlan_proto: ethernet protocol (0x8100, 0x88a8, 0x9x00)
> 
> It seems this patch is mixing stacked vlan's and the ability to
> set ethernet protocol field. Aren't the two capabilities really
> separate protocol extensions?

This patch does not affect stacked vlans at all. The "QinQ" in the
title refers to Nortel's 0x9100/0x9200/0x9300 protocol values, which
were marketed as "QinQ" (the protocol value was used to signal the
stacking depth to the switch to ease hw processing). I should
probably remove the "QinQ" label to avoid this misunderstanding.

All of those protocol values can be used in any stacking as desired.


-David
