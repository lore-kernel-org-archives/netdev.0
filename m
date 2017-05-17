From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: update latest firmware version supported
Date: Wed, 17 May 2017 13:58:44 +0000
Message-ID: <CY4PR12MB1432A8949198604FE97D1DC8C1E70@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <1494948412-7818-1-git-send-email-ganeshgr@chelsio.com>,<20170516.155308.1022881279018412401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nirranjan Kirubaharan <nirranjan@chelsio.com>,
        Indranil Choudhury <indranil@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0116.outbound.protection.outlook.com ([104.47.37.116]:26240
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750969AbdEQN6r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 09:58:47 -0400
In-Reply-To: <20170516.155308.1022881279018412401.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I will send the patch to net.

Thanks



From: David Miller <davem@davemloft.net>
Sent: Wednesday, May 17, 2017 1:23 AM
To: Ganesh GR
Cc: netdev@vger.kernel.org; Nirranjan Kirubaharan; Indranil Choudhury
Subject: Re: [PATCH net-next] cxgb4: update latest firmware version support=
ed
=A0  =20
From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 16 May 2017 20:56:52 +0530

> Change t4fw_version.h to update latest firmware version
> number to 1.16.43.0.
>=20
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

People are hitting regressions in 'net' due to using firmware allowed
by the current defines in combination with the FEC disabling commit.

So it doesn't make sense to "fix" this in 'net-next'.
    =
