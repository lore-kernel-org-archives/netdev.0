From: Mirko Lindner <mlindner@syskonnect.de>
Subject: Re: [PATCH] convert skge to pci_driver API (2nd try)
Date: Fri, 23 Jul 2004 13:23:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4100F51C.3030709@syskonnect.de>
References: <20040620112859.GA13794@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Ralph Roesler <rroesler@syskonnect.de>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040620112859.GA13794@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Christoph,

I'm sorry for this late answer. I was in holiday last weeks and couldn't 
check my company emails regulary.

Thanks a lot for the patch. Actually, we were busy with the new driver 
version 7.x which yukon ec and yukon2 support, which involves also the 
new init and deinit pci driver API.

The patch you have created is very similar to our work created about few 
months ago. The new driver version can be found at the moment for all 
testers on out page 
(http://www.syskonnect.de/syskonnect/support/driver/htm/sk9e21_lin.htm) 
and we are busy with additional stability and robustness tests. As soon 
as the driver is ready for the kernel stability we'll send the patches 
to Jeff and the KML.

Therefore we would like to keep our driver consistent and it's not 
possible for us to merge your changes into our code tree. Please don't 
apply the patch to the kernel tree, there are several problems with proc 
and locking which will probably lead to kernel oops. The new V7.05 
version includes all kernel patches since the last v6 driver release and 
additional code for handling the new descriptor (lists) logic of yukon 
ec and yukon2 cards, ethtool support, tcp-segmentation, power 
management. proc fs cleanups and changes for the interrupt moderation.

Cheers,
Mirko
