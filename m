From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH 3/3] rx_all e100 patch
Date: Wed, 26 Nov 2003 00:41:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126004149.A1264@sygehus.dk>
References: <3FC30AEE.7000005@candelatech.com> <20031125162152.D1107@sygehus.dk> <3FC39969.4030609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FC39969.4030609@candelatech.com>; from greearb@candelatech.com on Tue, Nov 25, 2003 at 10:03:21AM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2003 at 10:03:21AM -0800, Ben Greear wrote:
> Rask Ingemann Lambertsen wrote:
> > 
> > I don't understand this part of the code. The 55x docs say that the IP
> > checksum bytes are transferred to memory _following_ the FCS.
> 
> I can't find this in the docs, but it could easily be true.  If you have a page/section
> number, please let me know.

Section 6.4.3.4.1, page 102 if you go by the document page numbers or page
110 if you go by xpdf's page numbers.

> I don't appear to have hardware that takes this
> branch at any rate.  Anyone know which chipset/NIC has this particular rev-id?

The i82559. I wouldn't mind a few comment lines that map Intel's internal
names like D101M, D102 etc. into externally visible part numbers.

> Also, this should invalidate all of the hacks from the e100_D101M_checksum code...

I guess it does if you skb_put() the FCS along with the payload. I haven't
checked that, but I think you're right.

-- 
Regards,
Rask Ingemann Lambertsen
