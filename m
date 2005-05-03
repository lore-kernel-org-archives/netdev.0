From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Tue, 3 May 2005 07:52:06 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505030750010.16692@linux.site>
References: <Pine.LNX.4.61.0505021844480.16692@linux.site>
 <03d401c54f8c$03917fd0$5c10100a@pc.s2io.com> <20050503030620.GE12682@krispykreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        muhammad.shafiq@neterion.com, ramkrishna.vepa@neterion.com,
        netdev@oss.sgi.com,
        "'Ravinandan Arakali'" <ravinandan.arakali@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050503030620.GE12682@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005, Anton Blanchard wrote:

> 
> > [Ram] Yes, it is to ensure ordering as well as the flush of the io that is
> > required in some platforms.
> 
> If the flush of the IO is required I cant see how we can remove the read.
> 

Agreed. Can someone from neterion comment? Is a flush required, or is 
ordering all that's required here?

--
Arthur
