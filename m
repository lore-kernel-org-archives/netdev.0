From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Thu, 16 Dec 2010 18:53:58 +0100
Message-ID: <4D0A5236.5070900@grandegger.com>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>	<4D09D7B1.9080906@grandegger.com>
	<070E08D3134344CBB04FC2F201E778B7@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <070E08D3134344CBB04FC2F201E778B7-c0cKtqp5df7I9507bXv2FdBPR1lH4CV8@public.gmane.org>
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

On 12/16/2010 01:09 PM, Tomoya MORINAGA wrote:
> On Thursday, December 16, 2010 6:11 PM, Wolfgang Grandegger wrote:
> 
>> Ah, oh, I just realized that the register layout is almost identical to
>> the recently accepted *pch_can* driver. Tomoya, does pch_can use a c_can
>> core? Well, then it makes really sense to have a generic c_can driver
>> for the SPEAR, PCH, etc. Board specific details are handled via platform
>> definition. This driver already provides that functionality, IFAICS.
> 
> Hi Wolfgang,
> 
> It seems pch_can similar to c_can.
> However, sorry, I don't know if pch_can core is the same as c_can since
> LSI is provided by Intel.
> If necessary, please contact to Intel.

You could also try to use that driver. I'm rather sure that it does work
on your hardware as well.

Wolfgang.
