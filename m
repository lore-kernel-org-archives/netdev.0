From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/4] can: cc770: add
 driver core for the Bosch CC770 and Intel AN82527
Date: Sat, 26 Nov 2011 16:11:09 +0100
Message-ID: <4ED1018D.7020902@hartkopp.net>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-2-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1322214204-1121-2-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

Hello Wolfgang,

if you come to the point to re-post this patchset you may change this header
information just to a standard GPL header as you used for cc770_isa.c

No need to mention

- Derived from the old Socket-CAN i82527 driver:
- Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- Send feedback to <socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>

You really reworked the i82527 driver that much, that it is ok to present it
as your originated work ... my driver really wasn't that cool to mention it
here ;-)

Thanks & best regards,
Oliver


> --- /dev/null
> +++ b/drivers/net/can/cc770/cc770.c
> @@ -0,0 +1,895 @@
> +/*
> + * cc770.c - Bosch CC770 and Intel AN82527 network device driver
> + *
> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> + *
> + * Derived from the old Socket-CAN i82527 driver:
> + *
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + * 3. Neither the name of Volkswagen nor the names of its contributors
> + *    may be used to endorse or promote products derived from this software
> + *    without specific prior written permission.
> + *
> + * Alternatively, provided that this notice is retained in full, this
> + * software may be distributed under the terms of the GNU General
> + * Public License ("GPL") version 2, in which case the provisions of the
> + * GPL apply INSTEAD OF those given above.
> + *
> + * The provided data structures and external interfaces from this code
> + * are not restricted to be used by modules with a GPL compatible license.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
> + * DAMAGE.
> + *
> + * Send feedback to <socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
> + */
> +

> diff --git a/drivers/net/can/cc770/cc770.h b/drivers/net/can/cc770/cc770.h
> new file mode 100644


dito
