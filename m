From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/4] isdn/eicon: fix some message formatting errors
Date: Mon, 31 Oct 2016 13:42:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB020E4AB@AcuExch.aculab.com>
References: <20161029125605.13610-1-nicolas.iooss_linux@m4x.org>
 <20161029125605.13610-2-nicolas.iooss_linux@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Nicolas Iooss' <nicolas.iooss_linux@m4x.org>,
        Armin Schindler <mac@melware.de>,
        Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161029125605.13610-2-nicolas.iooss_linux@m4x.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Iooss
> Sent: 29 October 2016 13:56
> There are some inconsistent debug message formats in message.c. For
> example,
> 
>     dprintf("XDI CAPI: RC cancelled Id:0x02, Ch:%02x", e->Id, ch);
> 
> wrongly reports an ID of 2 and prints the entity ID as the channel ID.
> There are also object pointers which are used instead of the IDs.
> 
> All these inconsistent formats have been found by adding __printf
> attribute to myDbgPrint_...() functions (used by dbug()). As this makes
> the compiler to also complain about using "%ld" with unsigned int values
> (instead of "%u")...

The problem isn’t 'u' <=> 'd' but the 'l'.
They need fixing as well.
It only appears to work because the 64bit architectures pass enough
arguments in registers.

	David
