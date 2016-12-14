From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: remove abuse of VLAN DEI/CFI bit
Date: Tue, 13 Dec 2016 17:21:18 -0800
Message-ID: <20161213172118.2f55c503@xeon-e3>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org (moderated list:ETHERNET BRIDGE),
        dev@openvswitch.org (open list:OPENVSWITCH)
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35755 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbcLNBV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 20:21:26 -0500
Received: by mail-pf0-f174.google.com with SMTP id i88so780116pfk.2
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 17:21:26 -0800 (PST)
In-Reply-To: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  3 Dec 2016 10:22:28 +0100 (CET)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> This All-in-one patch removes abuse of VLAN CFI bit, so it can be passed
> intact through linux networking stack.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <michal.miroslaw@atendesoftware.=
pl>
> ---
>=20
> Dear NetDevs
>=20
> I guess this needs to be split to the prep..convert[]..finish sequence,
> but if you like it as is, then it's ready.
>=20
> The biggest question is if the modified interface and vlan_present
> is the way to go. This can be changed to use vlan_proto !=3D 0 instead
> of an extra flag bit.
>=20
> As I can't test most of the driver changes, please look at them carefully.
> OVS and bridge eyes are especially welcome.
>=20
> Best Regards,
> Micha=C5=82=C2=A0Miros=C5=82aw

Is the motivation to support 802.1ad Drop Eligability Indicator (DEI)?

If so then you need to be more verbose in the commit log, and lots more
work is needed. You need to rename fields and validate every place a
driver is using DEI bit to make sure it really does the right thing
on that hardware. It is not just a mechanical change.
