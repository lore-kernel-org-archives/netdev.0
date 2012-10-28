From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Information about napi_struct and net_device
Date: Mon, 29 Oct 2012 00:13:00 +0100
Message-ID: <20121028231300.GA27196@electric-eye.fr.zoreil.com>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com> <1351357421.30380.328.camel@edumazet-glaptop> <20121027182207.GA12858@electric-eye.fr.zoreil.com> <1351378943.30380.332.camel@edumazet-glaptop> <CALZVapkYdSRB9j+KnXdC7wT9iXqrZvXBcAK=Pk9uFoWwLgDNYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34290 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab2J1Xeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 19:34:37 -0400
Content-Disposition: inline
In-Reply-To: <CALZVapkYdSRB9j+KnXdC7wT9iXqrZvXBcAK=Pk9uFoWwLgDNYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Javier Domingo <javierdo1@gmail.com> :
[...]
>               inside of the net_device structure, I know I can take
> the net_device pointer as documented in [3], but how may  I obtain the
> napi_struct from the netdevice? or I am doing it the wrong way?

You are doing it the wrong way. The napi_struct you need is not embedded
here. See

$ less +/napi drivers/net/ethernet/realtek/8139cp.c

(first match in struct cp_private).

You should really read one of the existing drivers.

-- 
Ueimor
