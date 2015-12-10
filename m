From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Thu, 10 Dec 2015 23:06:44 +0200
Message-ID: <CAJ3xEMgOh9busKb7c5WF32=umGf8EdauOwQ1d_eDTJP95V1XLA@mail.gmail.com>
References: <56435508.9070802@mellanox.com>
	<CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
	<CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
	<CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
	<CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
	<CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
	<CAJ3xEMiSwVhUCTYcH+nWWBqrSwiykqsBFUZtBkirQtzsXVVL4A@mail.gmail.com>
	<CAJ3xEMhzB3UzfeJ8rvCmDFG57QnG5wdHPfahthxgR7Y-vvaiQg@mail.gmail.com>
	<CAOftzPieLwrF2V5YknHBRHxpGSsHqvqDoiHFPvXEcp3NUe24Gw@mail.gmail.com>
	<CAPWQB7GmJNYwmu5fSOWeLQxhdfPR4WgaD-=F7ZQCd6PtmQ=oYQ@mail.gmail.com>
	<CAJ3xEMiVUqTw-0cykq1x+kv3xKeD463TgmqOHypvy+ybPOVndg@mail.gmail.com>
	<CAPWQB7HkBFRozJzYNMDSZexJzmFVfDWc02Mkk1oTwwiCQtvPCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: Joe Stringer <joe@ovn.org>, Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33022 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbbLJVGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 16:06:45 -0500
Received: by ioef137 with SMTP id f137so9304702ioe.0
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 13:06:44 -0800 (PST)
In-Reply-To: <CAPWQB7HkBFRozJzYNMDSZexJzmFVfDWc02Mkk1oTwwiCQtvPCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 2:22 AM, Joe Stringer <joe@ovn.org> wrote:
> On 8 December 2015 at 13:23, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Tue, Dec 8, 2015 at 9:20 PM, Joe Stringer <joe@ovn.org> wrote:

>>>> Apologies for the delayed response, we haven't found anything
>>>> interesting yet although we've mostly looked at plain set-field
>>>> actions with a combination of kernel/userspace versions. I plan to
>>>> carve out some time later this week to take another look.

>>> (resending due to teething issues with new email and plain-text, sorry
>>> for the spam)

>>> As far as the mask, I briefly discussed this with Jarno and it seems
>>> like it could be something as simple as zeroing the ip_ttl mask in
>>> tnl_wc_init().

>> to make sure I follow, will that have the consequence that we (user +
>> kernel) will practically not be testing the ttl for these flows?

> Yes, it would cause userspace to 'wildcard' the field so the kernel
> flows that are installed will ignore it during lookup.

Cool, any chance this is gonna fit into your schedule to meet 4.4? if
not, for 4.5?

Also, can the patch be made simple/small enough to go into -stable as well?

Or.
