From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Fri, 13 Aug 2010 12:58:39 +0200
Message-ID: <4C65255F.4010709@grandegger.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>	<4C63B8F8.6090106@grandegger.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA2AB1@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>, "Wang, Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org" <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>,
	"arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: "Wang, Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5AB6E638E5A3E4B8F4406B113A5A19A28EA2AB1-QQHDSDV1ERZpB2pF5aRoyrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
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

On 08/13/2010 02:23 AM, Wang, Qi wrote:
>> -----Original Message-----
>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
>> Sent: Thursday, August 12, 2010 5:04 PM
>> To: Wang, Qi
>> Cc: Daniel Baluta; Masayuki Ohtak; meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org;
>> socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Khor, Andrew Chih
>> Howe; gregkh-l3A5Bk7waGM@public.gmane.org; arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org; Wang, Yong Y
>> Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
>>
>> On 08/12/2010 03:42 AM, Wang, Qi wrote:
>>>> -----Original Message-----
>>>> From: Daniel Baluta [mailto:daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
>>>> Sent: Wednesday, August 11, 2010 6:37 PM
>>>> To: Masayuki Ohtak
>>>> Cc: meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org; Wolfgang Grandegger;
>>>> socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Khor, Andrew
>> Chih
>>>> Howe; gregkh-l3A5Bk7waGM@public.gmane.org; arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org; Wang, Qi; Wang, Yong Y
>>>> Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
>>>>
>>>> Hi,
>>>>
>>>> 2010/8/11 Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>:
>>>>> CAN driver of Topcliff PCH
>>>>>
>>>>> Topcliff PCH is the platform controller hub that is going to be used in
>>>>> Intel's upcoming general embedded platform. All IO peripherals in
>>>>> Topcliff PCH are actually devices sitting on AMBA bus.
>>>>> Topcliff PCH has CAN I/F. This driver enables CAN function.
>>>>>
>>>>> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>>>>
>>>> I have a few questions:
>>>>
>>>> 1. Is your code based on Intel's CAN EP80579 ([1]) ?
>>> No.
>>
>> For curiosity, is the controller similar to the OKI MSM9225 or ML9620?
> The Topcliff IOH is developed by OKI actually.
> 
>>
>>>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
>>> Just take a look at kfifo.h. This structure has been changed. I remembered
>> there was a spin_lock from kfifo previously. Currently it's been removed, good.
>>> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to
>> use this structure and APIs?
>>
>> As I see it, the code related to that fifo is not used (== dead code)?
> I'm not familiar with kfifo structure, and I didn't like it because there need a spin_lock to use it.
>>
>>> Daniel,
>>>
>>> We're anxious to integrate those codes now. Perhaps it'll take us quite a long
>> time to use kfifo. How about implementing it with the next version?
>>
>> See above. What do you mean with the next version. The driver posted by
>> Masayuki is far away from being accepted as it does not yet comply with
>> the Socket-CAN driver API, to say the least.
> I've few experience on CAN driver and it's also the first time for OKI-san to write Can driver. Would you please give us a reference and we'll follow it up. We only read 'can.txt' from kernel document. Thank you for your help in advance.

You are welcome. I think I/we already gave useful hints on what is
missing and what examples to follow.

Wolfgang.
