From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH wg-linux-can-next devel 1/1] can: cc770: Fix indirect
 access deadlock on ISA cards
Date: Mon, 16 Jan 2012 10:26:56 +0100
Message-ID: <4F13ED60.5070602@grandegger.com>
References: <1326630094-3126-1-git-send-email-lkdev@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	socketcan-users@lists.berlios.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfgang Zarre <lkdev@essax.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1326630094-3126-1-git-send-email-lkdev@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/15/2012 01:21 PM, Wolfgang Zarre wrote:
> This fix avoids a deadlock if an interrupt occurs
> during consecutive port operations on ISA cards
> utilising indirect access via address and data
> port.
> 
> Tested on a B&R ISA card.
> 
> CC: linux-can@vger.kernel.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Wolfgang Zarre <lkdev@essax.com>

Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Next time, please drop the CC to the old BerliOS Socketcan mailing
lists. Marc, Oliver? Do we, should we, still send patches to the
"netdev@vger.kernel.org" as well.

Wolfgang.
