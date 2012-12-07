From: Cong Ding <dinggnu@gmail.com>
Subject: Re: [PATCH] fix initializer entry defined twice issue
Date: Fri, 7 Dec 2012 00:05:12 +0000
Message-ID: <20121207000511.GD2510@gmail.com>
References: <1354835928-617-1-git-send-email-dinggnu@gmail.com>
 <50C13159.2070901@fuel7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Otavio Salvador <otavio@ossystems.com.br>,
	Javier Martinez Canillas <javier@dowhile0.org>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick Trantham <patrick.trantham@fuel7.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50C13159.2070901@fuel7.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 06, 2012 at 05:59:21PM -0600, Patrick Trantham wrote:
> On 12/06/2012 05:16 PM, Cong Ding wrote:
> >the ".config_intr" is defined twice in both line 208 and 212.
> >
> >Signed-off-by: Cong Ding <dinggnu@gmail.com>
> >---
> >  drivers/net/phy/smsc.c |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
> >
> >diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> >index 16dceed..5cee6bd 100644
> >--- a/drivers/net/phy/smsc.c
> >+++ b/drivers/net/phy/smsc.c
> >@@ -205,7 +205,6 @@ static struct phy_driver smsc_phy_driver[] = {
> >  	/* basic functions */
> >  	.config_aneg	= genphy_config_aneg,
> >  	.read_status	= lan87xx_read_status,
> >-	.config_intr	= smsc_phy_config_intr,
> >  	/* IRQ related */
> >  	.ack_interrupt	= smsc_phy_ack_interrupt,
> 
> Hi Cong,
> 
> That looks like a mistake from my previous patch to that file.  Copy
> and paste fail.
> 
> The line should read:
> .config_init    = smsc_phy_config_init,
> 
> I can submit a patch once I get off work unless you beat me to it.
Thanks for the note. It's better that you submit a patch together with your
code.

- cong
