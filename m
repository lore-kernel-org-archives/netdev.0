From: Kai Germaschewski <kai-germaschewski@uiowa.edu>
Subject: Re: [BK PATCH] Make eth.c independent of dev->hard_header_len
Date: Sun, 29 Sep 2002 14:09:11 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209291406410.28578-100000@chaos.physics.uiowa.edu>
References: <3D974A3D.40207@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3D974A3D.40207@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Sep 2002, Jeff Garzik wrote:

> Kai Germaschewski wrote:
> > --- a/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
> > +++ b/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
> 
> I would prefer to keep the code inside TX_CHECKSUM in hamachi.c, hoping 
> somebody will complete it, not rip it out :)

I didn't really rip out anything. I just removed code cut'n'pasted from
net/ethernet/eth.c (+ slight modification to handle dev->hard_header_len
!= ETH_HLEN), since after the change we can use the generic
eth_trans_type() directly. The TX checksum thing is not at all affected by
that piece of code.

--Kai
