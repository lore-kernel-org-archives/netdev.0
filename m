From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: L2 switching in igb
Date: Mon, 14 Sep 2009 19:52:48 -0700
Message-ID: <5f2db9d90909141952r7ee9a4aj1d5e0dcdbceba111@mail.gmail.com>
References: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com>
	 <5f2db9d90909032135l26cfdba6n52329f6be75c16a5@mail.gmail.com>
	 <4AA8B317.2080706@voltaire.com> <4AA937A1.9070504@intel.com>
	 <4AAE14CC.2000609@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:55630 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933089AbZIOCwo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 22:52:44 -0400
Received: by pxi27 with SMTP id 27so2780152pxi.15
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 19:52:48 -0700 (PDT)
In-Reply-To: <4AAE14CC.2000609@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 3:02 AM, Or Gerlitz <ogerlitz@voltaire.com> wro=
te:
> To have VEPA support another bit has to be programmed... its the one =
that
> doesn't let the PF to forward a packet to a VF whose source mac match=
es the
> one in the packet (e.g multicast sender).

The bit I was referring to not setting would handle that.  By
disabling the DTXSWC local loopback bit the PF will not send anything
to the VFs or visa versa.

> Yes, lets do that. I'd like to suggest that a "VF programmable from u=
ser
> space" context =A0will contain a <mac, vlan-id, priority-bits, rate> =
tuple,
> such that in the absence of vlan tag, the VF driver will "sign" the p=
acket
> (skb) with vlan-id and priority-bits assigned by the admin and the PF=
 NIC
> will mandate that the VF originated traffic will not exceed the rate.

Well whenever I can get to it I will try to add that support.  In the
meantime I believe there is a BOF session covering "Virtual Ethernet
switch enhancements and configuration" at the Linux Plumbers Conf that
will cover some of this so hopefully we can come up with a solid plan
on how to address this.

Thanks,

Alex
