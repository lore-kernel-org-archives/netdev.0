From: "Krishnakumar. R" <krishnakumar@naturesoft.net>
Subject: Re: RTL8139
Date: 17 Dec 2003 21:23:24 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1071662782.3485.8.camel@l5ac210.l5.laser5.co.jp>
References: <3FDDF085.6060603@secline.com.br>  <3FDE10BE.2000208@pobox.com>
Reply-To: krishnakumar@naturesoft.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Leo Cambilargiu <leo@secline.com.br>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FDE10BE.2000208@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

When i am trying to download the manual
of 8139C from realtek site, I am getting
8139C(L) manual. And as per that the 
device id should be 8129 for 8139C(L).

So there is a possibility that if you 
enable the CONFIG_8139TOO_8129 you might 
get the card working.

Leo,
Have you enabled 
"Support for older RTL-8129/8130 boards" 
option in the make menuconfig(that will enable the 
 CONFIG_8139TOO_8129 )? If not then can you enable 
it and try out ?

Regards,
KK.




On Tue, 2003-12-16 at 04:51, Jeff Garzik wrote:
> Leo Cambilargiu wrote:
> > Hello readers:
> > 
> > I purchased a couple of encore ENL832-tx NIC's that Linux doesn't 
> > recognize.
> > 
> > they are based on RTL8139C (06117S1)
> > 
> > The module 8139too (2.4.23) doesn't load.  It behaves as though no 
> > recognized hardware exists.
> > 
> > Any comments?
> 
> 
> Probably you need to add PCI ids to 8139too.c...
> 
> 
> 
