From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next V4 3/9] Altera TSE: Add Altera Ethernet Driver
 MSGDMA File Components
Date: Wed, 12 Mar 2014 19:48:28 -0500
Message-ID: <CAOwfj2NUjVZjg2KinBNA9pRBBbUWhw86GcXEaLdmAyK_1SPfDQ@mail.gmail.com>
References: <1394655334-29547-1-git-send-email-vbridgers2013@gmail.com>
	<1394655334-29547-4-git-send-email-vbridgers2013@gmail.com>
	<1394656275.3915.32.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394656275.3915.32.camel@joe-AO722>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Wed, Mar 12, 2014 at 3:31 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-03-12 at 15:15 -0500, Vince Bridgers wrote:
>> This patch adds the MSGDMA soft IP support for the Altera Triple
>> Speed Ethernet driver.
>
> []
>
>> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>> ---
>> V4: - Modify use of dev_* to netdev_* where possible
>
> Hi again Vince.
>
> trivia:
>
> It'd be better to also use the netif_<foo> forms too.
>
> This can be done later in a follow-on patch if desired.
>
>> diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/ethernet/altera/altera_msgdma.c
> []
>> +void msgdma_reset(struct altera_tse_private *priv)
>> +{
> []
>> +     if ((counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) &&
>> +         (netif_msg_drv(priv)))
>> +             netdev_warn(priv->dev,
>> +                         "TSE Rx mSGDMA resetting bit never cleared!\n");
>
>         if (counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR)
>                 netif_warn(priv, drv, priv->dev,
>                            "TSE Rx mSGDMA resetting bit never cleared!\n");
>
> []
>
>> +     if ((counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) &&
>> +         (netif_msg_drv(priv)))
>> +             netdev_warn(priv->dev,
>> +                         "TSE Tx mSGDMA resetting bit never cleared!\n");
>
>         if (counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR)
>                 netif_warn(priv, drv, priv->dev,
>                            "TSE Tx mSGDMA resetting bit never cleared!\n");
>
> cheers, Joe
>

You had mentioned this before, I guess I missed this. My apologies,
I'll pick this up in V5 with the misc other improvements.

All the best,

Vince
