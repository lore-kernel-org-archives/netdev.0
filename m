From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 5/7] bnx2x: do not rollback VF MAC/VLAN filters we did
 not configure
Date: Sun, 5 Mar 2017 10:13:19 +0000
Message-ID: <BL2PR07MB2306505E42203BE1F718F6F78D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-6-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Michal Schmidt <mschmidt@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0042.outbound.protection.outlook.com ([104.47.38.42]:59904
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752019AbdCEKtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Mar 2017 05:49:03 -0500
In-Reply-To: <20170303160834.4125-6-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On failure to configure a VF MAC/VLAN filter we should not attempt to
> rollback filters that we failed to configure with -EEXIST.

Is this theoretical or did you actually manage to hit it?
If so, did it involve non-linux VFs?

Asking as linux VFs don't actually send multiple vlan/umac configurations
Via same request, and with a single filter per-message you're not expected
to ever do rollback.
