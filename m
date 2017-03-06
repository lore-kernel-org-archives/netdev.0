From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net 5/7] bnx2x: do not rollback VF MAC/VLAN filters we did
 not configure
Date: Mon, 6 Mar 2017 15:05:05 +0100
Message-ID: <24cc5b8c-c0c4-3951-5d5e-9e353746699a@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-6-mschmidt@redhat.com>
 <BL2PR07MB2306505E42203BE1F718F6F78D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753752AbdCFOrw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 09:47:52 -0500
In-Reply-To: <BL2PR07MB2306505E42203BE1F718F6F78D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 5.3.2017 v 11:13 Mintz, Yuval napsal(a):
>> On failure to configure a VF MAC/VLAN filter we should not attempt to
>> rollback filters that we failed to configure with -EEXIST.
>
> Is this theoretical or did you actually manage to hit it?
> If so, did it involve non-linux VFs?
>
> Asking as linux VFs don't actually send multiple vlan/umac configurations
> Via same request, and with a single filter per-message you're not expected
> to ever do rollback.

This one is theoretical, found by reading the code, not actually hitting 
the rollback case.

Michal
