From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] fjes: Fix unnecessary spinlock_irqsave
Date: Tue, 10 May 2016 16:13:41 +0300
Message-ID: <8e0d4e29-30b4-af2d-733f-4cf9d229237c@cogentembedded.com>
References: <1462843729-32414-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: isimatu.yasuaki@jp.fujitsu.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33012 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbcEJNNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 09:13:44 -0400
Received: by mail-lf0-f47.google.com with SMTP id y84so14420973lfc.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 06:13:43 -0700 (PDT)
In-Reply-To: <1462843729-32414-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/10/2016 4:28 AM, Taku Izumi wrote:

> commit-bd5a256 introduces a deadlock bug in fjes_change_mtu().

    scripts/checkpatch.pl now enforces a certain commit citing style, yours 
doesn't match it.

> This spin_lock_irqsave() is obviously unnecessary.
>
> This patch eliminates unnecessary spin_lock_irqsave() in
> fjes_change_mtu()
>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
[...]

    The "Fixes:" tag would also be in order...

MBR, Sergei
