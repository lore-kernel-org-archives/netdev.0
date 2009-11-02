From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] Driver for the Microchip MCP251x SPI CAN
	controllers
Date: Mon, 02 Nov 2009 20:28:55 +0100
Message-ID: <4AEF32F7.7060101@grandegger.com>
References: <1256824214-21420-1-git-send-email-chripell@fsfe.org>	<4AED5589.3090106@grandegger.com>
	<cabda6420911020706r340ef073qea40527f09551a8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <cabda6420911020706r340ef073qea40527f09551a8a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

christian pellegrin wrote:
> On Sun, Nov 1, 2009 at 10:31 AM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wrote:
>> Hi Christian,
>>
> 
> Hi,
> 
>> there are a few. In general, please check the usage of {} for if
> 
> sorry for missing this: I read your link below: I missed that rule on
> first reading! And I tend to trust checkpatch.pl too much ;-)
> 
>> statements and check if "if (ret)" should be used instead of "if (ret <
>> 0)" if 0 means success and !0 failure. I don't have a MCP251x hardware
> 
> ok, I misunderstood this to. Now I think it's ok.
> 
> I'm replying to this thread with v2 patch. I'm rebasing the
> differences against SVN trunk too, but I'm waiting to send them until
> this patch is accepted in net-next-2.6 since their are only of
> cosmetic nature.

That's fine. of course.

[snip]
>>> +#include <linux/can/core.h>
>> I don't think you need "can/core.h"?
>>
> 
> I tried without but there are some dependencies in "can/dev.h" to some
> netdev stuff that are broken if I omit it.

Hm, sounds like a bug. I will check a.s.a.p.

Wolfgang.
