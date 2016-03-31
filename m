From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH net-next 0/8] add TX timestamping via cmsg
Date: Wed, 30 Mar 2016 21:08:58 -0400
Message-ID: <CADAM+B1osNNwVpg1R_kAFW8m75mr15_usDa=gmqpBA+xwyA_fg@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
	<20160331003744.GA3300@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33397 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbcCaBI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 21:08:59 -0400
Received: by mail-vk0-f65.google.com with SMTP id a62so9377698vkh.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 18:08:59 -0700 (PDT)
In-Reply-To: <20160331003744.GA3300@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 8:38 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Wed, Mar 30, 2016 at 06:37:20PM -0400, Soheil Hassas Yeganeh wrote:
>> I will follow up with another patch to enable timestamping for
>> active TFO (client-side TCP Fast Open) and also setting packet
>> mark via cmsgs.
> Can you share more details on what 'setting packet mark' does?

I meant, since SOL_SOCKET-level csmg's will be processed for all
protocols, users should be able to override sk->sk_mark via command
messages when possible similar to what the following patch did for
packet sockets:
http://patchwork.ozlabs.org/patch/527991/

It'll be a tiny followup patch.

> Nice patches!

Thank you so much!

Cheers,
Soheil
