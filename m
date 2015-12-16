From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next v3 3/3] geneve: Remote Checksum Offload support
Date: Wed, 16 Dec 2015 09:10:27 -0800
Message-ID: <CAEh+42ixrSG7sXF0AjFDQKSmSojyzVYWe_MsJan1CnEXhvRTpA@mail.gmail.com>
References: <1449779866-3704097-1-git-send-email-tom@herbertland.com>
 <1449779866-3704097-4-git-send-email-tom@herbertland.com> <CAEh+42hCrCOqnPf2Sj5po6MjtJie=kL2QX4MmBqcAquJp4RUng@mail.gmail.com>
 <CALx6S37jRCwwZHDSVY6DOY3u9EUkHnQsupFa5zzx-KWk7pE5AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:38252 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934221AbbLPRKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 12:10:49 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 7AA62203C0
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 17:10:48 +0000 (UTC)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BDF28202F8
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 17:10:47 +0000 (UTC)
Received: by mail-qk0-f169.google.com with SMTP id t125so74126129qkh.3
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 09:10:47 -0800 (PST)
In-Reply-To: <CALx6S37jRCwwZHDSVY6DOY3u9EUkHnQsupFa5zzx-KWk7pE5AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 8:41 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Dec 10, 2015 at 1:17 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Thu, Dec 10, 2015 at 12:37 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> Add support for remote checksum offload in both the normal and GRO
>>> paths. netlinks command are used to enable sending of the Remote
>>> Checksum Data, and allow processing of it on receive.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>
>> Tom, can you please split this patch off and mark it as RFC or similar?
>>
>> I don't have any objections to implementing remote checksum offload
>> for Geneve in general but I think that it's pretty clear that the
>> format that you are using here is not the direction that the protocol
>> is going to evolve. We don't need to fragment the protocol by applying
>> this at this time.
>
> The first two patches were accepted, you should have enough to
> implement the remote checksum patches in the TLV format so you can
> take it from here.

Thanks, I'll pick it up from here.
