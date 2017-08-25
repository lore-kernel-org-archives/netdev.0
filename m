From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net] cxgb4: Fix stack out-of-bounds read due to wrong size
 to t4_record_mbox()
Date: Fri, 25 Aug 2017 20:57:32 +0000
Message-ID: <MWHPR12MB1600CB171EE1C4F2961555B7C89B0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <04759fe12e6a8eb8e36e46060b907f02c269a826.1503692361.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Hariprasad Shenai <hariprasad@chelsio.com>,
        Sai Vemuri <svemuri@redhat.com>
To: Stefano Brivio <sbrivio@redhat.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0105.outbound.protection.outlook.com ([104.47.37.105]:10512
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932319AbdHYU5g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 16:57:36 -0400
In-Reply-To: <04759fe12e6a8eb8e36e46060b907f02c269a826.1503692361.git.sbrivio@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Stefano Brivio <sbrivio@redhat.com>
| Sent: Friday, August 25, 2017 1:48 PM
| =A0  =20
| Passing commands for logging to t4_record_mbox() with size
| MBOX_LEN, when the actual command size is actually smaller,
| causes out-of-bounds stack accesses in t4_record_mbox() while
| copying command words here:
| ...

Thanks for catching this.  Definitely a bug.  Odd because
that's not what I checked into our out-of-kernel repository.
And the corresponding code in the cxgb4vf driver is correct.

So yes, ACK!

Casey=
