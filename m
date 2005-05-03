From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Mon, 2 May 2005 19:11:53 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505021844480.16692@linux.site>
References: <200504051836.j35IanDD005402@guinness.s2io.com>
 <Pine.LNX.4.61.0505021459240.16692@linux.site> <20050503014034.GC12682@krispykreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid Grossman <leonid.grossman@neterion.com>,
        muhammad.shafiq@neterion.com, ramkrishna.vepa@neterion.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050503014034.GC12682@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 3 May 2005, Anton Blanchard wrote:

> 
> I didnt know mmiowb is supposed to be a replacement for PCI write
> posting. Most architectures define mmiowb as nothing and so will be
> broken with your change.
> 

I thought that an arch was supposed to define mmiowb() if it needs 
it. In this case, the readq() is only being used for the side-effect 
of ordering the previous writes (the neterion folks can correct me 
if I'm wrong). 

--
Arthur
