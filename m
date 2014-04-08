From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: cpsw: fix dual_emac VLAN issue
Date: Tue, 8 Apr 2014 20:57:35 +0200
Message-ID: <CAGm1_kuRbv_1WPyTTAQNiD=Q4eDfg14uEK_TMxnSZ8wEqHvS=A@mail.gmail.com>
References: <1396969110-3114-1-git-send-email-yegorslists@googlemail.com>
 <1396969110-3114-2-git-send-email-yegorslists@googlemail.com> <20140408.141528.2130884658575478739.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:63273 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757714AbaDHS54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 14:57:56 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so1390101pdi.30
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 11:57:55 -0700 (PDT)
In-Reply-To: <20140408.141528.2130884658575478739.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 8, 2014 at 8:15 PM, David Miller <davem@redhat.com> wrote:
> From: yegorslists@googlemail.com
> Date: Tue,  8 Apr 2014 16:58:30 +0200
>
>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>
>> CPSW shows following behavior: some stations in LAN don't
>> answer CPSW's ARP request. Kernel 3.2 could talk to all stations in
>> the same LAN.
>>
>> Use the same cpsw_ale_add_vlan procedure as in kernel 3.2.
>>
>> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
>
> The CPSW driver was not added to the tree until v3.3, so saying
> you're restoring behavior that existed in v3.2 doesn't make any
> sense at all.

It would make sense, if I had said, that it was TI's PSP kernel
(http://arago-project.org/git/projects/?p=linux-am33x.git;a=commit;h=6afa003a0b06a0376c941436b38204ba2edc4a98).
This was the first time dual_emac was introduced. I will include this
info in v2.

Today a new thread was opended on TI's forum concerning this issue:
http://e2e.ti.com/support/arm/sitara_arm/f/791/p/333389/1162614.aspx

Yegor
