From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Tue, 3 May 2005 13:06:20 +1000
Message-ID: <20050503030620.GE12682@krispykreme>
References: <Pine.LNX.4.61.0505021844480.16692@linux.site> <03d401c54f8c$03917fd0$5c10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Arthur Kepner'" <akepner@sgi.com>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        muhammad.shafiq@neterion.com, ramkrishna.vepa@neterion.com,
        netdev@oss.sgi.com,
        "'Ravinandan Arakali'" <ravinandan.arakali@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ramkrishna Vepa <ram.vepa@neterion.com>
Content-Disposition: inline
In-Reply-To: <03d401c54f8c$03917fd0$5c10100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> [Ram] Yes, it is to ensure ordering as well as the flush of the io that is
> required in some platforms.

If the flush of the IO is required I cant see how we can remove the read.

Anton
