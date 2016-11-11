From: Casey Leedom <leedom@chelsio.com>
Subject: [RFC PATCH net-next] net: ethtool: add support for forward error
 correction modes
Date: Fri, 11 Nov 2016 19:51:36 +0000
Message-ID: <DM5PR12MB178630AFB893C17362A4C09BC8BB0@DM5PR12MB1786.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0118.outbound.protection.outlook.com ([104.47.36.118]:63456
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934727AbcKKUmH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 15:42:07 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

N.B.  Sorry I'm not able to respond to the original message since I
wasn't subscribed to netdev when it was sent a couple of weeks ago.

This feature is something that Chelsio's cxgb4 driver needs.
As we've tested our adapters against a number of switches,
we've discovered a few which use varying defaults for FEC.
And when Auto-Negotiation isn't used (or even possible with
Optical Links), we need to be able to control turning FEC on/off.

For our part, we default FEC Off for Optical Transceivers.
For Copper, we read the Cable's EEPROM to determine
how to default FEC.  For some switches this works, but
for at least one where that switch enables FEC for Optical
Transceivers, it doesn't.  For that switch we had to hard
wire FEC on.  Obviously that's not a good solution and we
need an administrative interface so the system
administrator can configure our adapter to use the
appropriate FEC setting to match that of the switch.

So this is basically a long-winded ACK of Vidya's patch
and we would immediately implement this new ethtool API
as soon as it's available.

Casey
