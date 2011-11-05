From: David Lamparter <equinox@diac24.net>
Subject: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Sat,  5 Nov 2011 17:54:13 +0100
Message-ID: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:38697 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368Ab1KERCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 13:02:54 -0400
Received: from jupiter.n2.diac24.net ([2001:8d8:81:5c2:21b:fcff:fe4c:9e6f])
	by spaceboyz.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.76)
	(envelope-from <equinox@diac24.net>)
	id 1RMjds-0008WI-3r
	for netdev@vger.kernel.org; Sat, 05 Nov 2011 18:02:52 +0100
Received: from equinox by jupiter.n2.diac24.net with local (Exim 4.76)
	(envelope-from <equinox@diac24.net>)
	id 1RMjdo-005EkU-Qv
	for netdev@vger.kernel.org; Sat, 05 Nov 2011 18:02:51 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi DaveM, hi everyone,


this kernel patch, together with the iproute2 userspace support,
allows creating 802.1ad S-VLAN devices.

This feature might have weird interactions with hardware VLAN
acceleration. I've done my best to make sure it doesn't break
802.1Q, but my access to hardware is rather limited. I did grep
& scan all drivers for maybe-affected vlan behaviour and found
nothing. I've tested on e1000, forcedeth, virtio and a Kirkwood
ARM.

It'd be nice to get this into the next merge window to get some
people with funny hardware a nice smoke trail...


Cheers,

David L.
