From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 2/2] can: ti hecc module : add platform
	specific	initialization callback.
Date: Tue, 23 Feb 2010 15:34:02 +0100
Message-ID: <4B83E75A.7040101@grandegger.com>
References: <1266845762-7809-1-git-send-email-srk@ti.com>
	<20100222.154741.56894014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: srk-l0cyMroinI0@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100222.154741.56894014.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
> Date: Mon, 22 Feb 2010 19:06:02 +0530
> 
>> CAN module on AM3517 requires programming of IO expander as part
>> of init sequence - to enable CAN PHY. Added platform specific
>> init callback to handle this.
>>
>> Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
>> Acked-by: Anant Gole <anantgole-l0cyMroinI0@public.gmane.org>
> 
> Please address Wolfgang's feedback comments.

Yes, as Marc suggested, please follow the at91_can.c example using
transceiver_switch.

Wolfgang.
