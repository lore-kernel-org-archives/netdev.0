From: Mirko Lindner <demon@pro-linux.de>
Subject: Re: [PATCH] convert skge to pci_driver API (2nd try)
Date: Wed, 11 Aug 2004 23:19:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411A8D5B.10707@pro-linux.de>
References: <20040620112859.GA13794@lst.de> <4100F51C.3030709@syskonnect.de> <411A7514.30908@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@syskonnect.de>, Christoph Hellwig <hch@lst.de>,
        netdev@oss.sgi.com, Ralph Roesler <rroesler@syskonnect.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <411A7514.30908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

sorry for the absence. I think my last email was wrongly expressed. Yes, 
I know the procedure of the kernel development and we've applied all the 
current maintime patches/changes into the sk98lin V7 driver. It's not a 
problem. Our driver has a similar function as Christoph patch and we can 
merge Christoph work to our code. The problem is that some people 
reported us driver crashes with the new patch during the init and/or 
exit phase. The patch seems to be having some problems (as example 
ProcFS init) and is not included in the kernel at the moment. In 
consequence of this we would keep the kernel driver consistent and 
submit you as soon as possible a tested driver with new init-function 
and some other changes. It would be difficult to maintain two patchsets 
and fixing the old driver V6.

Mirko


Jeff Garzik wrote:
> Mirko Lindner wrote:
> 
>> Therefore we would like to keep our driver consistent and it's not 
>> possible for us to merge your changes into our code tree. Please don't 
> 
> 
> 
> Unfortunately it is a requirement of Linux development that you track 
> the upstream tree.
> 
> In particular, you "fell off the map" for months without a driver update 
> or email, so it seems perfectly reasonable that other patches would get 
> applied in the meantime.
> 
>     Jeff
> 
> 
> 
> !DSPAM:411a752655587707918480!
> 
