From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 23 Aug 2012 23:03:21 +0200
Message-ID: <50369A99.2070405@gmail.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56961 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259Ab2HWVCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 17:02:07 -0400
Received: by eeil10 with SMTP id l10so455538eei.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 14:02:05 -0700 (PDT)
In-Reply-To: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/08/2012 21:29, Vlad Yasevich a =C3=A9crit :
> This series of patches provides an ability to add VLAN IDs to the bri=
dge
> ports.  This is similar to what can be found in most switches.  The b=
ridge
> port may have any number of VLANs added to it including vlan 0 for un=
tagged
> traffic.  When vlans are added to the port, only traffic tagged with =
particular
> vlan will forwarded over this port.  Additionally, vlan ids are added=
 to FDB
> entries and become part of the lookup.  This way we correctly identif=
y the FDB
> entry.
>
> There are still pieces missing.  I don't yet support adding a static =
fdb entry
> with a particular vlan.  There is no netlink support for carrying a v=
lan id.
>
> I'd like to hear thoughts of whether this is usufull and something we=
 should
> persue.
>

Do you think this might allow for per VLAN spanning tree (having ports =
in forwarding state or=20
blocking state depending on the VLAN) in the future?

	Nicolas.
