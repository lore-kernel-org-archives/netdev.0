From: Daniel Baluta <daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Fri, 13 Aug 2010 09:11:50 +0300
Message-ID: <AANLkTinEtrpE8UAW2+ybRP7YmQ0aPBp5fq2q7P+-HMgV@mail.gmail.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>
	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>
	<4C63B8F8.6090106@grandegger.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA2AB1@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>, "Wang, Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org" <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>,
	"arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

Hi,
> I'm not familiar with kfifo structure, and I didn't like it because there need a spin_lock to use it.

It seems that you don't need to use your own kfifo. Socket-CAN core has
it's internal queues, you only have to fit in this infrastructure.

>>
>> > Daniel,
>> >
>> > We're anxious to integrate those codes now. Perhaps it'll take us quite a long
>> time to use kfifo. How about implementing it with the next version?
>>
>> See above. What do you mean with the next version. The driver posted by
>> Masayuki is far away from being accepted as it does not yet comply with
>> the Socket-CAN driver API, to say the least.
> I've few experience on CAN driver and it's also the first time for OKI-san to write Can driver. Would you please give us a reference and we'll follow it up. We only read 'can.txt' from kernel document. Thank you for your help in advance.

Oliver's email should be your starting point. Read the code from net/can and see
how other drivers are built.

As I previously said I'm interested in writing a driver for CAN
EP80579 controller,
but the start is pretty slow. Since your controller seems to be pretty
similar we
can do some things in common.

I can help you, if you send me a pointer to your CAN controller
datasheet + eventually
grant me access to your repo.

thanks,
Daniel.
