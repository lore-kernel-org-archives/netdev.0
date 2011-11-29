From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/4] can: cc770: add
 support for the Bosch CC770 and Intel AN82527
Date: Tue, 29 Nov 2011 12:03:24 +0100
Message-ID: <4ED4BBFC.6010306@grandegger.com>
References: <1322557890-6363-1-git-send-email-wg@grandegger.com>	<4ED4B838.2060307@pengutronix.de>
	<4ED4B93B.10709@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>,
	socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED4B93B.10709-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/29/2011 11:51 AM, Marc Kleine-Budde wrote:
> On 11/29/2011 11:47 AM, Marc Kleine-Budde wrote:
>> On 11/29/2011 10:11 AM, Wolfgang Grandegger wrote:
>>> Already since a while we have support for the Bosch CC770 and Intel
>>> AN82527 CAN controllers in our out-of-tree Socket-CAN repository.
>>>
>>> In the meantime I found a TQM855L board with two AN82527 on it,
>>> which allowed me to provide and test a generic platform driver
>>> as well.
>>>
>>> Changes since v1:
>>>
>>> - remove version.h includes
>>> - some minor corrections in the ISA bus driver
>>> - add platform header file to the driver core
>>> - add generic platform driver
>>> - add and update device tree nodes for tqm8xx and tqm8548
>>>
>>> Changes since v2:
>>>
>>> - correct license text as suggest by Oliver Hartkopp
>>> - use the new module_platform_driver function
>>> - provide get_berr_counter callback for cc770
>>> - improve CAN error state change handling
>>> - more comprehensive cc770_isa driver description
>>>
>>> Changes since v3:
>>>
>>> - pre-define pr_fmt()
>>> - use KBUILD_MODNAME instead of DRV_NAME
>>> - use ARRAY_SIZE() whenever appropriate
>>> - use variable name "o" for message objects consistantly
>>> - use proper error code for cc770_probe_chip
>>> - remove unneeded member priv->open_time
>>> - remove unnecessary masking of u8 variables (with 0xff)
>>> - use "!skb" instead of "skb == NULL"
>>> - CC770_MSG_MAX now limits the number of messages read in the ISR
>>> - use "|" instead of "+" to combine bit masks
>>> - remove return code check of platform_get_resource() in remove function
>>> - remove postal address from GPL copyright text
>>> - fix WARNING: __packed is preferred over __attribute__((packed))
>>> - some more minor fixes (casts, white space, etc.)
>>
>> Feel free to add by Acked-by to patches 1 and 2.
>                    ^^
> my

Will do for the next version. You may also want to ack them explicitly.

Thanks,

Wolfgang.
