From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/6] netdev: bfin_mac: handler RX
	status errors
Date: Thu, 21 Jan 2010 04:42:45 -0500
Message-ID: <8bd0f97a1001210142l45169edfidde08eb1fef18665@mail.gmail.com>
References: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
	<20100121.011445.26519711.davem@davemloft.net> <8bd0f97a1001210131w74d53c82h3f548e645bb14be7@mail.gmail.com>
	<20100121.013358.45891896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, pmeerw@pmeerw.net,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:52980 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab0AUJnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:43:10 -0500
Received: by ywh36 with SMTP id 36so5264441ywh.15
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 01:43:05 -0800 (PST)
In-Reply-To: <20100121.013358.45891896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 04:33, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> On Thu, Jan 21, 2010 at 04:14, David Miller wrote:
>>> This patch set doesn't apply cleanly to net-next-2.6, please
>>> respin.
>>
>> i thought you said you merged the patch i sent out earlier ?
>> bfin_mac: use the newer CLKBUFOE bit name via asm/dpmc.h
>
> I did, to net-2.6 since it fixed a build.
>
> If you are sending me patches that depend upon net-2.6 changes,
> you have to mention that in your patch submission.

np

> Otherwise how do I know that I need to merge net-2.6 into
> net-next-2.6 in order to apply your patches?

it seems odd to me to have a "next" tree that doesnt include all of
the "now" changes, so i just assumed the tree state

not saying you should change your development flow, just pointing out
where the misunderstanding came from
-mike
