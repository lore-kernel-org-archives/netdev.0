From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 25 Sep 2007 22:26:31 +0900 (JST)
Message-ID: <20070925.222631.116063075.yoshfuji@linux-ipv6.org>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122244.15989.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	joe@perches.com, tglx@linutronix.de, oliver@hartkopp.net,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de,
	yoshfuji@linux-ipv6.org
To: urs@isnogud.escape.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:45989 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbXIYNYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 09:24:54 -0400
In-Reply-To: <20070925122244.15989.5@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070925122244.15989.5@janus.isnogud.escape.de> (at Tue, 25 Sep 2007 14:20:34 +0200), Urs Thuermann <urs@isnogud.escape.de> says:

> Index: net-2.6.24/drivers/net/can/vcan.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ net-2.6.24/drivers/net/can/vcan.c	2007-09-25 13:32:23.000000000 +0200
> @@ -0,0 +1,208 @@
> +/*
> + * vcan.c - Virtual CAN interface
> + *
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions, the following disclaimer and
> + *    the referenced file 'COPYING'.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + * 3. Neither the name of Volkswagen nor the names of its contributors
> + *    may be used to endorse or promote products derived from this software
> + *    without specific prior written permission.
> + *
> + * Alternatively, provided that this notice is retained in full, this
                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> + * software may be distributed under the terms of the GNU General
> + * Public License ("GPL") version 2 as distributed in the 'COPYING'
> + * file from the main directory of the linux kernel source.
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
> + * Send feedback to <socketcan-users@lists.berlios.de>
> + *
> + */

I'm not a lawyer, but the following lines:

| + * Alternatively, provided that this notice is retained in full, this
                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| + * software may be distributed under the terms of the GNU General
| + * Public License ("GPL") version 2 as distributed in the 'COPYING'
| + * file from the main directory of the linux kernel source.

make this whole licence imcompatible with GPL.
I do think you need to allow people to select GPLv2 only.

--yoshfuji
