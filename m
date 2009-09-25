From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
Date: Fri, 25 Sep 2009 22:29:56 +0200
Message-ID: <20090925202956.GA3462@del.dom.local>
References: <20090921201157.GA5460@del.dom.local>
 <4ABA9058.3010605@free.fr>
 <20090925131038.GA14778@ff.dom.local>
 <20090925134052.GA1661@linux-mips.org>
 <20090925183504.GA3307@del.dom.local>
 <4ABD1EF3.7040400@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ABD1EF3.7040400@upmc.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2009 at 09:50:11PM +0200, Bernard Pidoux wrote:
> Hi Jarek,
> 
> patch applied to 2.6.31.1 kernel keeping your other AX25 debugging patches.

Actually, only one of them is for debugging.
> 
> So far, so good !

Very strange...;-) It seems I might have been wrong and the previous
patch could actually fix those oopses. Then it would point at some
problems while starting netrom connections as the main suspect.

Thanks,
Jarek P.
