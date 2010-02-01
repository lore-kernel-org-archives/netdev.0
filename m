From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next-2.6 PATCH 2/5] if_link: Add SR-IOV configuration
 	methods
Date: Mon, 1 Feb 2010 12:33:41 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FDD55C136@rrsmsx501.amr.corp.intel.com>
References: <20100130103842.26633.73429.stgit@localhost.localdomain>
	 <20100130103947.26633.78452.stgit@localhost.localdomain>
 <15ddcffd1001310625k3a1c1010w57e7cf62986c56ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29479 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697Ab0BATdv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 14:33:51 -0500
In-Reply-To: <15ddcffd1001310625k3a1c1010w57e7cf62986c56ef@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
>Sent: Sunday, January 31, 2010 6:26 AM


>In the same manner that vconfig does for 8021q devices, except for VID
>there's a need
>to let the user control on the egress qos mapping (vlan priority bits)
>per VF (I don't think it
>need to go per skb priority). Where for NIC HW which supports setting
>the VID only, the
>packets will be marked with a default priority.

To be honest, Or, this completely slipped my mind. I'll add it to my
to-do list.

If it's OK with you, I'd prefer to get this set of patches in as-is and
add the egress qos stuff later. A lot of people have been asking for
these patches, so I'd rather not delay for this feature.

-Mitch
