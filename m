From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2 1/3] can: at91_can: clean up usage of AT91_MB_RX_FIRST
	and	AT91_MB_RX_NUM
Date: Tue, 18 Jan 2011 10:26:11 +0100
Message-ID: <4D355CB3.8000508@grandegger.com>
References: <1294752085-30151-1-git-send-email-mkl@pengutronix.de>	<1294752085-30151-2-git-send-email-mkl@pengutronix.de>
	<4D349D8C.3010403@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D349D8C.3010403-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 01/17/2011 08:50 PM, Marc Kleine-Budde wrote:
> On 01/11/2011 02:21 PM, Marc Kleine-Budde wrote:
>> This patch cleans up the usage of two macros which specify the mailbox
>> usage. AT91_MB_RX_FIRST and AT91_MB_RX_NUM define the first and the
>> number of RX mailboxes. The current driver uses these variables in an
>> unclean way; assuming that AT91_MB_RX_FIRST is 0;
>>
>> This patch cleans up the usage of these macros, no longer assuming
>> AT91_MB_RX_FIRST == 0.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> 
> Any comments on this?

Looks fine too me. You can add my:

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Thanks,

Wolfgang.
