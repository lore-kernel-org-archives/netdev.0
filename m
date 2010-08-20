From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Fri, 20 Aug 2010 09:59:17 +0200
Message-ID: <4C6E35D5.2080500@grandegger.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>	<4C63B8F8.6090106@grandegger.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA2AB1@shsmsx501.ccr.corp.intel.com>
	<4C65255F.4010709@grandegger.com>
	<000f01cb402d$34b675b0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Wang,
	Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	"Wang, Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Morinaga <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000f01cb402d$34b675b0$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

Hi Ohtake,

On 08/20/2010 08:01 AM, Masayuki Ohtake wrote:
> Hi Wolfgang,
> 
>>>>>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
>>>>> Just take a look at kfifo.h. This structure has been changed. I remembered
>>>> there was a spin_lock from kfifo previously. Currently it's been removed, good.
>>>>> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to
>>>> use this structure and APIs?
>>>>
>>>> As I see it, the code related to that fifo is not used (== dead code)?
>>> I'm not familiar with kfifo structure, and I didn't like it because there need a spin_lock to use it.
> 
> We are about to study kfifo infra structure.
> I have a question.
> 
> It seems all CAN drivers accepted by upstream don't use kfifo infrastructure, right ?

Right!

> (I couldn't see message with "grep kfifo * in drivers/net/can")
> 
> If yes, why should we use the kfifo ?
> If no, please show me the kfifo reference driver

Sorry, nobody (of the socketcan core developers) said that kfifo should
be used. We believe, that an additional queuing of CAN messages is *not*
needed at all. Just eliminate the related code and follow more closely
the existing mainline drivers.

Wolfgang.
