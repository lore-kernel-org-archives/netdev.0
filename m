From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH 3/3] sky2: Remove failure cases for sky2_rx_start
Date: Thu, 28 Jan 2010 07:30:56 +0900
Message-ID: <392fb48f1001271430w4abef167o550f86f853bf31cd@mail.gmail.com>
References: <4B605652.6020400@ring3k.org> <20100127091024.2ac97d81@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:55834 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756287Ab0A0Wa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 17:30:57 -0500
Received: by ywh36 with SMTP id 36so66646ywh.15
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 14:30:56 -0800 (PST)
In-Reply-To: <20100127091024.2ac97d81@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/1/28 Stephen Hemminger <shemminger@vyatta.com>:
> On Thu, 28 Jan 2010 00:05:54 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
>
>> sky2_rx_start() can no longer fail, so remove redundant code pathes.
>>
>> Signed-off-by: Mike McCormack <mikem@ring3k.org>
>
> This can't work right if MTU is increased. The buffers need to be reallocated
> in change_mtu(); and yes it could fail when getting the new buffers.

Thanks for the feedback.  I will rework the patches.

Mike
