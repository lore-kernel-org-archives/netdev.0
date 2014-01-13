From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 13 Jan 2014 17:46:31 +0400
Message-ID: <52D3EE37.9070403@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 27-12-2013 1:37, Sergei Shtylyov wrote:

> Add support for the CAN controller found in Renesas R-Car SoCs.

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
> The patch is against the 'linux-can-next.git' repo.

> Changes in version 5:
> - removed the code specific to the mailbox mode handling and added the code
>    for the FIFO mode, dropping support for CAN_CTRLMODE_ONE_SHOT;
> - stop accumulating errors in the byte 1 of an error frame;
> - added #define RCAR_CAN_CTLR_CANM for CTLR.CANM field, added 'CANM_' infix to
>    all its values;
> - replaced ~RCAR_CAN_CTLR_CANM_FORCE_RESET with ~RCAR_CAN_CTLR_CANM;
> - added polling for the CAN reset status bit when going from/to CAN reset.

    Wolfgang, Marc, there has been no feedback from you on the last version, 
working in FIFO mode. Ping!

WBR, Sergei

