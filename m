From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Mon, 1 Nov 2010 16:15:01 +0900
Message-ID: <002701cb7994$81db1350$66f8800a@maildom.okisemi.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

On Friday, October 29, 2010 9:57 PM : Marc Kleine-Budde wrote:
>>>> SW must check busy flag of CAN register.
>>>> This is a Topcliff HW specification.
>>> Maybe the busy check could also be done *before* the Message RAM is
>>> accessed to avoid (or minimize) waiting.
>> Yes, *before* is right.
>> If there is *after* processing, this is a bug.
>> Can you see anyway ?
>Sorry I don't understand what you mean.

Sorry, my English had mistake. I show my comment below again.
 - If there is *after* processing, this is a bug.
 - Can you see the point anywhere ?

> You probably know the datasheet, but I don't, although I've printed
> chapter 13 from the Intel Controller Hub EG20T datasheet, but it's 50+
> pages. If the hardware needs the busy waiting in the hot tx path a
> pointer to the respective section in the manual is a good idea. Just
> something like:

Though "Oliver Hartkopp" found the place of Datasheet EG20T and notified with the mailing-list,
Have you read the following ?
http://edc.intel.com/Platforms/Atom-E6xx/#hardware

>>> You have to change the definition of the regs struct a bit:
>>>>  u32 if1_mcont;
>>>>  u32 if1_data[4];
>>>>  u32 reserve2;
>> Uh, I can't find this. Where is this ?
>Here's a patch to illustrate what I meant:
I understand.


Thanks, Tomoya(OKI SEMICONDUCTOR CO., LTD.)
