From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Wed, 12 Jan 2011 09:47:58 +0100
Message-ID: <4D2D6ABE.7000405@grandegger.com>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>	<4D2829C5.5020206@grandegger.com>	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>	<4D2C14FE.7080903@grandegger.com>
	<4D2CA0AA.6080505@grandegger.com> <4D2CD34B.8000609@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfram Sang <wsa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2CD34B.8000609-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 01/11/2011 11:01 PM, Marc Kleine-Budde wrote:
> On 01/11/2011 07:25 PM, Wolfgang Grandegger wrote:
> 
> [...]
> 
>> I was told that Bosch's page for the C_CAN is here:
>>
>>  http://www.semiconductors.bosch.de/en/ipmodules/can/canipmodules/c_can/c_can.asp
>>
>> There it's also written for what bus interfaces the C_CAN is available for, e.g.:
>>
>>   "The ASIC version is delivered with the AMBA APB bus interface from ARM."
> 
> On ARM we also have the AMBA bus abstraction in Linux, but I've never
> worked with it. IIRC Wolfram (Cc'ed) has recently touched it.
> 
>> which is obviously used in the "Platform Controller Hub" eg20t.
> 
> But in the pch, they've attached the AMBA to the PCI bus.

Ah, right. Anyway, with that driver we are prepared to handle other bus
interfaces by adding another bus-sensitive driver in
"drivers/net/can/c_can".

Wolfgang.
