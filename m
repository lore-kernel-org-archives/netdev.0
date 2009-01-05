From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to
 request_firmware()
Date: Sun, 04 Jan 2009 16:11:44 -0800 (PST)
Message-ID: <20090104.161144.119147757.davem@davemloft.net>
References: <1230626497.24796.26.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: jaswinder@infradead.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1230626497.24796.26.camel@jaswinder.satnam>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Date: Tue, 30 Dec 2008 14:11:37 +0530

> Firmware blob looks like this...
>         u8 firmware_major
>         u8 firmware_minor
>         u8 firmware_fix
>         u8 pad
>         __be32 start_address
>         __be32 length (total, including BSS sections to be zeroed)
>         data... (in __be32 words, which is native for the firmware)
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

I'm simply tired of fighting this, so applied.
