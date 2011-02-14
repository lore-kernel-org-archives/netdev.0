From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v8 1/1] can: c_can: Added support for
	Bosch C_CAN controller
Date: Sun, 13 Feb 2011 23:26:23 -0800 (PST)
Message-ID: <20110213.232623.85402516.davem@davemloft.net>
References: <1297666006-8627-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: bhupesh.sharma-qxv4g6HH51o@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1297666006-8627-1-git-send-email-bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Date: Mon, 14 Feb 2011 12:16:46 +0530

> Bosch C_CAN controller is a full-CAN implementation which is compliant
> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
> obtained from:
> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> c_can/users_manual_c_can.pdf
> 
> This patch adds the support for this controller.
> The following are the design choices made while writing the controller
> driver:
> 1. Interface Register set IF1 has be used only in the current design.
> 2. Out of the 32 Message objects available, 16 are kept aside for RX
>    purposes and the rest for TX purposes.
> 3. NAPI implementation is such that both the TX and RX paths function
>    in polling mode.
> 
> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>

Applied, thanks.
