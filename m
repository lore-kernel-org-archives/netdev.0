From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 2/2] ravb: add workaround for clock when resuming with
 WoL enabled
Date: Tue, 1 Aug 2017 16:27:17 +0300
Message-ID: <4e0cd03e-a2f0-2a41-7c66-903a0eed03a6@cogentembedded.com>
References: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
 <20170801101437.9020-3-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33214 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751832AbdHAN1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 09:27:20 -0400
Received: by mail-lf0-f43.google.com with SMTP id d17so7038024lfe.0
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 06:27:20 -0700 (PDT)
In-Reply-To: <20170801101437.9020-3-niklas.soderlund+renesas@ragnatech.se>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 01:14 PM, Niklas Söderlund wrote:

> The renesas-cpg-mssr clock driver are not yet aware of PSCI sleep where
> power is cut to the SoC. When resuming from this state with WoL enabled
> the enable count of the ravb clock is 1 and the clock driver thinks the
> clock is already on when PM core enables the clock and increments the
> enable count to 2. This will result in the ravb driver failing to talk
> to the hardware since the module clock is off. Work around this by
> forcing the enable count to 0 and then back to 2 when resuming with WoL
> enabled.
> 
> This workaround should be reverted once the renesas-cpg-mssr clock
> driver becomes aware of this PSCI sleep behavior.
> 
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
