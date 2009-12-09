From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2] add the driver for Analog Devices Blackfin on-chip
	CAN controllers
Date: Wed, 09 Dec 2009 11:16:44 +0100
Message-ID: <4B1F790C.2060201@grandegger.com>
References: <1260353277-30902-1-git-send-email-21cnbao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, "H.J. Oertel" <oe-pJ9TYRvN+WE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1260353277-30902-1-git-send-email-21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Barry Song wrote:
> Signed-off-by: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: H.J. Oertel <oe-pJ9TYRvN+WE@public.gmane.org>
> ---
> 	-v2: cleanup according to Wolfgang Grandegger's feedback
> 	1.delete some unnecessary debug print
> 	2.delete ndo_tx_timeout entry as it is not needed in can 
> 	3.use alloc_can_skb, alloc_can_err_skb instead of netdev_alloc_skb
> 	4.add timeout while polling can status
> 	5.rename BFIN_CAN_READ/WRITE_MSG to bfin_can_read/write_data
> 	6.use kernel BIT instead of bit shift
> 	7.use void __iomem * for CAN memory base memory instead of u32
> 	8.delete "dev->last_rx = jiffies" since it is not needed now
> 	9.delete redundant "echo_skb" member in bfin can private data
> 	10.follow can convention to use "_" instead of "-" for file names

Did you consider using structs instead of these ugly and cumbersome
macro functions? This was my major criticisms with your previous version
of the patch.

Wolfgang.
