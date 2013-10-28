From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Mon, 28 Oct 2013 20:19:20 +0200
Message-ID: <CAJZOPZJ3J7T=i2QXQPr80Qb-V8RT3uPJaNFDnrOpYxJ1Mt_LNQ@mail.gmail.com>
References: <526D2F8F.1070204@mellanox.com>
	<alpine.LFD.2.03.1310271017120.19783@intel.com>
	<CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
	<alpine.LFD.2.03.1310271635540.15400@intel.com>
	<CAJZOPZLAg+5dYS=bUCkDMyYq8EmA_uvEv1Zi+drq6Qqe5onrzQ@mail.gmail.com>
	<alpine.LFD.2.03.1310281049210.31450@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:53718 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab3J1STV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 14:19:21 -0400
Received: by mail-pb0-f41.google.com with SMTP id um1so2601949pbc.28
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 11:19:20 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1310281049210.31450@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 7:59 PM, Joseph Gasparakis
> On Mon, 28 Oct 2013, Or Gerlitz wrote:
>> On Mon, Oct 28, 2013 at 1:44 AM, Joseph Gasparakis wrote:

>> > VXLAN implementation is not done like VLAN. VLANs are stacked on top of
>> > real interfaces and what you are saying makes sense. VXLAN however is
>> > using ip[6]_tunnel_xmit, and this is why we need to notify all the
>>
>> As the name of the ndo you added ndo_add_rx_vxlan_port suggests -- HW
>> needs that for RX offloads. So basically, what I am saying is: in a
>> similar manner that we already program the NIC "over which" the vxlan
>> instance is set to listen on the multicast address which is associated
>> with that vxlan segement, lets give them a hint that packets arriving
>> on this group are vxlan ones, so they can use it for programming
>> steering rules.
>
> Why don't you write up some code so everyone has something to look at?
> Then we can see what makes sense to do in terms of the existing or new ndos.

sure, code talks, indeed, still, looking on net-next, for the current
ndo there's no in tree consumer unless I miss anything, did I?

Or.
