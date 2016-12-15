From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: sfc: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 15 Dec 2016 22:50:26 +0100
Message-ID: <CAC=8w92BFiVcP8dPuKjDd_xF0MWozCb+9=WgdP+SuntdwekJsw@mail.gmail.com>
References: <1481757173-16000-1-git-send-email-tremyfr@gmail.com> <741a20e3-5b7a-bfe8-a7af-81bacd736e16@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <741a20e3-5b7a-bfe8-a7af-81bacd736e16@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarod,

On 12/15/16, Jarod Wilson <jarod@redhat.com> wrote:
> On 2016-12-14 6:12 PM, Philippe Reynes wrote:
>> The ethtool api {get|set}_settings is deprecated.
>> We move this driver to new api {get|set}_link_ksettings.
>>
>> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
>> ---
>>  drivers/net/ethernet/sfc/ethtool.c    |   35 ++++++++++++-------
>>  drivers/net/ethernet/sfc/mcdi_port.c  |   60
>> ++++++++++++++++++++------------
>>  drivers/net/ethernet/sfc/net_driver.h |   12 +++---
>>  3 files changed, 65 insertions(+), 42 deletions(-)
>
> What about drivers/net/ethernet/sfc/falcon/ethtool.c? Coming in a
> separate patch?

Yes, I send only one driver per patch.
I'll send another patch for this driver.

Philippe
