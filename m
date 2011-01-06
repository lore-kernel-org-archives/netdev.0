From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Thu, 06 Jan 2011 21:08:56 +0100
Message-ID: <4D262158.4030301@grandegger.com>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>	<20110106.113356.102556872.davem@davemloft.net>
	<4D261AAA.5030005@grandegger.com> <4D261BA4.2020003@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D261BA4.2020003-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Hi Marc,

On 01/06/2011 08:44 PM, Marc Kleine-Budde wrote:
> Hello Wolfgang,
> 
> On 01/06/2011 08:40 PM, Wolfgang Grandegger wrote:
>> On 01/06/2011 08:33 PM, David Miller wrote:
>>> From: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>>> Date: Tue, 4 Jan 2011 15:29:55 +0530
>>>
>>>> Bosch C_CAN controller is a full-CAN implementation which is compliant
>>>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
>>>> obtained from:
>>>> http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
>>>
>>> Can someone please review this driver submission?
>>
>> Yes, of course. I'm still on holiday, hope to find some time tomorrow.
> 
> If this driver will be merged, we'll have two drivers for the same can
> core in the tree. The other one is the pch_can. What do you think should
> be the mid term perspective for ccan based hardware?

Yes, I know. Unfortunately, we did realize rather late the the PCH
controller is a C_CAN clone and the OKI/Intel ppls did not tell us
either. Therefore I asked Bhupesh to provide a SJA1000-a-like interface
for the C_CAN, which would allow us to provide an alternative PCI driver
"pch_pci.c" for the PCH. If that driver works well on the PCH hardware
as well, we should merge the best of both, if necessary, and then
finally remove the pch_can driver. Would that be a reasonable proposal.

Wolfgang.
