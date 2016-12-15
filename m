From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] net: sfc: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 15 Dec 2016 14:59:03 -0500
Message-ID: <741a20e3-5b7a-bfe8-a7af-81bacd736e16@redhat.com>
References: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>,
        linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-12-14 6:12 PM, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/sfc/ethtool.c    |   35 ++++++++++++-------
>  drivers/net/ethernet/sfc/mcdi_port.c  |   60 ++++++++++++++++++++------------
>  drivers/net/ethernet/sfc/net_driver.h |   12 +++---
>  3 files changed, 65 insertions(+), 42 deletions(-)

What about drivers/net/ethernet/sfc/falcon/ethtool.c? Coming in a 
separate patch?

-- 
Jarod Wilson
jarod@redhat.com
