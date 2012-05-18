From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] STA2X11 CAN: CAN driver for the STA2X11 board
Date: Fri, 18 May 2012 08:00:33 +0200
Message-ID: <4FB5E581.1090209@grandegger.com>
References: <1337288364-17572-1-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1337288364-17572-1-git-send-email-federico.vaga@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2012 10:59 PM, Federico Vaga wrote:
> Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
> Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
> Cc: Alan Cox <alan@linux.intel.com>
> ---
>  drivers/net/can/Kconfig       |   11 +
>  drivers/net/can/Makefile      |    1 +
>  drivers/net/can/sta2x11_can.c | 1085 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1097 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/sta2x11_can.c

Thanks for your contribution. At a first glance, this driver looks
similar to the pch_can and the c_can driver. It seems that a C_CAN based
controller is used on that board as well. If that's true, it should be
handled by the C_CAN driver. To get ride of the obsolete pch_can driver,
I sent some time ago the patch "[RFC/PATCH] c_can: add driver for the
PCH CAN controller":

  http://marc.info/?t=132991563600003&r=1&w=4

I could serve as base of a generic c_can_pci driver.

Wolfgang.
