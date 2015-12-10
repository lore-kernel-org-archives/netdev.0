From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next v3 3/3] geneve: Remote Checksum Offload support
Date: Thu, 10 Dec 2015 13:17:29 -0800
Message-ID: <CAEh+42hCrCOqnPf2Sj5po6MjtJie=kL2QX4MmBqcAquJp4RUng@mail.gmail.com>
References: <1449779866-3704097-1-git-send-email-tom@herbertland.com> <1449779866-3704097-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:52171 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862AbbLJVRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 16:17:51 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 5F8FF205E1
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 21:17:50 +0000 (UTC)
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 89384205DD
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 21:17:49 +0000 (UTC)
Received: by qgea14 with SMTP id a14so164720767qge.0
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 13:17:48 -0800 (PST)
In-Reply-To: <1449779866-3704097-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2015 at 12:37 PM, Tom Herbert <tom@herbertland.com> wrote:
> Add support for remote checksum offload in both the normal and GRO
> paths. netlinks command are used to enable sending of the Remote
> Checksum Data, and allow processing of it on receive.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Tom, can you please split this patch off and mark it as RFC or similar?

I don't have any objections to implementing remote checksum offload
for Geneve in general but I think that it's pretty clear that the
format that you are using here is not the direction that the protocol
is going to evolve. We don't need to fragment the protocol by applying
this at this time.
