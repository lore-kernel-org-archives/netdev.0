From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next-2.6 PATCH 2/5] if_link: Add SR-IOV configuration
	methods
Date: Sun, 31 Jan 2010 16:25:43 +0200
Message-ID: <15ddcffd1001310625k3a1c1010w57e7cf62986c56ef@mail.gmail.com>
References: <20100130103842.26633.73429.stgit@localhost.localdomain>
	 <20100130103947.26633.78452.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:48023 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab0AaOZp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 09:25:45 -0500
Received: by bwz27 with SMTP id 27so2442496bwz.21
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2010 06:25:43 -0800 (PST)
In-Reply-To: <20100130103947.26633.78452.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:

> +struct ifla_vf_vlan {
> + =A0 =A0 =A0 __u32 vf;
> + =A0 =A0 =A0 __s32 vlan; /* 0 - 4095, -1 disables VLAN filter */
> +};

Jeff,

In the same manner that vconfig does for 8021q devices, except for VID
there's a need
to let the user control on the egress qos mapping (vlan priority bits)
per VF (I don't think it
need to go per skb priority). Where for NIC HW which supports setting
the VID only, the
packets will be marked with a default priority.

Or.
