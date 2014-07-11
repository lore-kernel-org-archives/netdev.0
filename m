From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Fri, 11 Jul 2014 12:57:10 +0800
Message-ID: <CAJxxZ0Ow8E3KYbAS-RNKmxJ+2uanFod1ZmvtVYcAUTmE0ep4gg@mail.gmail.com>
References: <1404985944-30463-1-git-send-email-sonic.adi@gmail.com>
	<20140710.165342.434372844542249917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:53104 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaGKE5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 00:57:11 -0400
Received: by mail-ob0-f177.google.com with SMTP id wp18so605649obc.22
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 21:57:11 -0700 (PDT)
In-Reply-To: <20140710.165342.434372844542249917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, Jul 11, 2014 at 7:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Sonic Zhang <sonic.adi@gmail.com>
> Date: Thu, 10 Jul 2014 17:52:24 +0800
>
>> +     if (i < budget && !test_bit(NAPI_STATE_NPSVC, &napi->state)) {
>> +             napi_complete(napi);
>> +             enable_irq(IRQ_MAC_RX);
>> +     }
>
> Drivers are not supposed to test this bit directly.
>
> If you have not exhausted the budget, and the chip has no more work to
> do, you should unconditionally exit the NAPI poll.

OK. I will send a new patch.

Regards,

Sonic
