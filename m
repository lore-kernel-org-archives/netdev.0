From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: NETIF_N_NTUPLE - should it control flow classification?
Date: Wed, 17 May 2017 10:25:54 +0000
Message-ID: <BLUPR0701MB20049CF05B3D3FA8BBC3599F8DE70@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0072.outbound.protection.outlook.com ([104.47.41.72]:39197
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753630AbdEQKZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 06:25:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code-reading a bit, and I'm not sure of the exact definition of said bit;
Couldn't really deduce from the comment "N-tuple filters supported"
what falls under its jurisdiction and failed to find any other documentatio=
n.

I understand RFS acceleration is going to be disabled for an interface
when this is unset, and some drivers also pro-actively take action when
it's changed via set_features().

But there's seems to be some disagreement about the effect it has over
ethtool's flow classification [ETHTOOL_SRXCLSRLINS] -
Most drivers don't seem to care, but at least the intel drivers are
blocking received configurations in case user removed the feature.
