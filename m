From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Mon, 24 Nov 2003 01:05:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124010501.C1657@sygehus.dk>
References: <3FB94311.10004@candelatech.com> <20031119123556.A7622@sygehus.dk> <3FBB8D61.6010106@candelatech.com> <20031120173404.A1538@sygehus.dk> <3FC077B1.1050807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux netdev mailing list <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <3FC077B1.1050807@candelatech.com>; from greearb@candelatech.com on Sun, Nov 23, 2003 at 01:02:41AM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Nov 23, 2003 at 01:02:41AM -0800, Ben Greear wrote:

[Intel i82557/8/9 Ethernet chips]

Saving bad frames to memory is controlled by CB_CFIG_SAVE_BAD_FRAMES in byte
6. Saving the FCS to memory is controlled by CB_CFIG_CRC_IN_MEM in byte 18.
See drivers/net/e100/e100_config.h.

> It's less clear what happens when you turn off the FCS generation.  One part of
> the document mentions it gets it from RAM, which I assume means it uses the last
> part of the DMA'd packet???

Yes. The last four octets from the skb will be interpreted as an FCS by
whichever board receives that frame.

> Another explanation of the transmit state machine does
> not mention that you can disable FCS generation...  I'm going to print this out
> and read it again in detail...

There is a bit in the command word of a TX command which disables FCS
generation. I can't find that bit defined in drivers/net/e100/e100.h, so
you'll have to find it in the docs.

-- 
Regards,
Rask Ingemann Lambertsen
