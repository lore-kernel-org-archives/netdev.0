From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 20/35] drivers/isdn: Convert remaining uses of
 pr_warning to pr_warn
Date: Fri, 17 Feb 2017 09:49:26 +0100
Message-ID: <1487321366.10826.2.camel@tiscali.nl>
References: <cover.1487314666.git.joe@perches.com>
         <5b05531314db5d6b9c40e2e082c4f6a495df4ae6.1487314667.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5b05531314db5d6b9c40e2e082c4f6a495df4ae6.1487314667.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-02-16 at 23:11 -0800, Joe Perches wrote:
> To enable eventual removal of pr_warning
> 
> This makes pr_warn use consistent for drivers/isdn
> 
> Prior to this patch, there were 20 uses of pr_warning and
> 3 uses of pr_warn in drivers/isdn
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/isdn/gigaset/interface.c        |  2 +-

Gigaset hunk looks good to me:
    Acked-by: Paul Bolle <pebolle@tiscali.nl>

>  drivers/isdn/hardware/mISDN/avmfritz.c  | 17 +++++++++--------
>  drivers/isdn/hardware/mISDN/hfcmulti.c  |  8 ++++----
>  drivers/isdn/hardware/mISDN/hfcpci.c    |  4 ++--
>  drivers/isdn/hardware/mISDN/hfcsusb.c   |  4 ++--
>  drivers/isdn/hardware/mISDN/mISDNipac.c |  4 ++--
>  drivers/isdn/hardware/mISDN/mISDNisar.c | 10 +++++-----
>  drivers/isdn/hardware/mISDN/netjet.c    |  8 ++++----
>  drivers/isdn/hardware/mISDN/w6692.c     | 12 ++++++------
>  drivers/isdn/mISDN/hwchannel.c          |  8 ++++----
>  10 files changed, 39 insertions(+), 38 deletions(-)


Paul Bolle
