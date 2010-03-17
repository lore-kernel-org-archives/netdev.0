From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Uclinux-dist-devel] [PATCH] can: bfin_can: switch to common
	Blackfin can header
Date: Wed, 17 Mar 2010 01:25:39 -0400
Message-ID: <8bd0f97a1003162225i439d9900mfdc03eca5de0ff6e@mail.gmail.com>
References: <1268150589-27123-1-git-send-email-vapier@gentoo.org>
	<20100316.212830.50212878.davem@davemloft.net>
	<8bd0f97a1003162145i77f65158ne255b28239e1b595@mail.gmail.com>
	<20100316.220232.170244945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100316.220232.170244945.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Wed, Mar 17, 2010 at 01:02, David Miller wrote:
> From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> On Wed, Mar 17, 2010 at 00:28, David Miller wrote:
>>> From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
>>>> The MMR bits are being moved to this header, so include it.
>>>
>>> I can't actually apply this since this asm/bfin_can.h header
>>> doesn't even exist in the tree yet so this change will
>>> break the build.
>>
>> Linus was supposed to pull my tree, but if that isnt going to happen
>> for 2.6.34, then just apply the patch for 2.6.35
>
> That's what I was going to do, apply it to net-next-2.6
> but I can't even do that until the asm/bfin_can.h change
> appears in Linus's tree.

if the next tree is merged into linux-next, then the header is already there
-mike
