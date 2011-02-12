From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Sat, 12 Feb 2011 15:24:42 +0100
Message-ID: <4D56982A.5010302@grandegger.com>
References: <1297419478-27667-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1297419478-27667-1-git-send-email-bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
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

On 02/11/2011 11:17 AM, Bhupesh Sharma wrote:
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
> ---
> Changes since V6:
> 1. Added check for calling netif_stop_queue() in case next TX object
>    is busy.
> 2. Added logic *not* to copy data to rx'ed RTR frames.
> 3. Moved enums, defines and structs present in c_can.h file to the respective
>    c-file where they are actually used.
> 4. Corrected message object busy status routine by using a better name
>    and design approach.
> 5. Moved *set_bittiming* call to the *c_can_chip_config* function.

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Thanks for your contribution. As soon as the patch is accepted, I will
send a patch for the PCH CAN.

Wolfgang.
