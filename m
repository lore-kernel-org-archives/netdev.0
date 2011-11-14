From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH 0/5] ks8851 MAC and eeprom updates
Date: Mon, 14 Nov 2011 10:17:13 -0800
Message-ID: <4EC15B29.7020909@codeaurora.org>
References: <1319681870-11972-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Sebastien Jan <s-jan@ti.com>,
	Ben Dooks <ben@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319681870-11972-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/11 19:17, Stephen Boyd wrote:
> I pulled this patch series off the netdev list[1] when the eeprom
> reading didn't work for my ks8851 and I wanted the mac address to be
> read out at boot. It all seems to work well, so I'm posting it here
> again, slightly cleaned up and simplified, for inclusion.
[snip]
>
>  drivers/misc/eeprom/eeprom_93cx6.c   |   88 ++++++
>  drivers/net/ethernet/micrel/Kconfig  |    2 +
>  drivers/net/ethernet/micrel/ks8851.c |  513 ++++++++++++----------------------
>  drivers/net/ethernet/micrel/ks8851.h |   15 +-
>  include/linux/eeprom_93cx6.h         |    8 +
>  5 files changed, 278 insertions(+), 348 deletions(-)

Any comments on this series?

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
