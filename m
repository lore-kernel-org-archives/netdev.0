From: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into per-interface tables
Date: Tue, 10 Jan 2017 00:53:46 +0300
Message-ID: <8cddkd-etc.ln1@banana.localnet>
References: <20170106153026.24785-1-lorenzo@google.com> <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:50192 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdAIWUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:20:18 -0500
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <linux-netdev-2@m.gmane.org>)
        id 1cQiIO-0004PV-3x
        for netdev@vger.kernel.org; Mon, 09 Jan 2017 23:20:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> wrote:
> On 1/6/17 8:30 AM, Lorenzo Colitti wrote:
> > This patch adds a per-interface sysctl to have the kernel put
> > autoconf routes into different tables. This allows each interface
> > to have its own routing table if desired.  Choosing the default
> > interface, or using different interfaces at the same time on a
> > per-socket or per-packet basis) can be done using policy routing
> > mechanisms that use as SO_BINDTODEVICE / IPV6_PKTINFO, mark-based
> > routing, or UID-based routing to select specific routing tables.

> Why not use the VRF capability then? create a VRF and assign the interface to it. 
> End result is the same -- separate tables and the need to use a bind-to-device API to hit those routes.

Show *really working* config with VRF & IPv6?

In my tests - kernel unable to accept DAD, fill logs with "ICMPv6: RA: ndisc_router_discovery failed to add default route"
and nothing work. VRF interface don't contains IPv6 address.
