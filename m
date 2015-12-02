From: Joe Stringer <joe@ovn.org>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Wed, 2 Dec 2015 10:01:43 -0800
Message-ID: <CAOftzPieLwrF2V5YknHBRHxpGSsHqvqDoiHFPvXEcp3NUe24Gw@mail.gmail.com>
References: <56435508.9070802@mellanox.com> <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
 <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
 <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
 <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
 <CAJ3xEMiSwVhUCTYcH+nWWBqrSwiykqsBFUZtBkirQtzsXVVL4A@mail.gmail.com> <CAJ3xEMhzB3UzfeJ8rvCmDFG57QnG5wdHPfahthxgR7Y-vvaiQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>, Joe Stringer <joe@ovn.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:41845 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964799AbbLBSCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 13:02:07 -0500
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 8EA3E41C0AA
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 19:02:05 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 3fDFMCjuGg1K for <netdev@vger.kernel.org>;
	Wed,  2 Dec 2015 19:02:04 +0100 (CET)
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	(Authenticated sender: joe@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 0D64441C084
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 19:02:03 +0100 (CET)
Received: by ykdv3 with SMTP id v3so56156552ykd.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 10:02:02 -0800 (PST)
In-Reply-To: <CAJ3xEMhzB3UzfeJ8rvCmDFG57QnG5wdHPfahthxgR7Y-vvaiQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 November 2015 at 05:37, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Thu, Nov 19, 2015 at 5:40 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sat, Nov 14, 2015 at 8:45 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>> On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>
>>>>> I agree that this UNSPEC issue on v2.3 could do with a bit of a closer
>>>>> look. I'll see if I can find some time for it. Alternatively if you're
>>>>> willing and have bandwith, I'd be curious if it's related to the
>>>>> masked set field feature introduced in Linux-4.0.
>>
>>>> so what would you suggest here? run with 3.19 or earlier?
>>
>>> On second thought, I think if it were related to that then userspace
>>> v2.4 would not exhibit the problem. I'd have to dig in to see why it
>>> occurs.
>>
>> Any findings?
>
> Hi Joe/Jesse,
>
> Apart from Haggai's note on the TTL, I am pinging you here for the 2nd
> time... can you please let me know how
> this goes on your end?

Apologies for the delayed response, we haven't found anything
interesting yet although we've mostly looked at plain set-field
actions with a combination of kernel/userspace versions. I plan to
carve out some time later this week to take another look.
