From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 0/3] net: Linn Ethernet Packet Sniffer driver
Date: Wed, 18 Feb 2015 22:08:30 +0100
Message-ID: <20150218210830.GA7778@localhost.localdomain>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1424181053.git.stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 17, 2015 at 02:03:30PM +0000, Stathis Voukelatos wrote:
> The command string for packet matching is stored in module RAM
> and consists of a sequence of 16-bit entries. Each entry includes
> an 8-bit command code and and 8-bit data value. Valid command
> codes are:
> 0 - Don't care
> 1 - Match: packet data must match command string byte
> 2 - Copy: packet data will be copied to FIFO
> 3 - Match/Stamp: if packet data matches string byte, a timestamp
>                  is copied into the FIFO
> 4 - Copy/Done: packet data will be copied into the FIFO.
>                This command terminates the command string.

Why do you need to expose this interface to user space at all?  Why
not just time stamp every frame?

How does the "Match" command work?  The frame must have one particular
byte?  That can't be right.  Please explain.

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
