From: Adam Anthony <AAnthony@sbs.com>
Subject: RE: [PATCH] /driver/net/wan/sbs520
Date: Mon, 10 Jan 2005 12:49:23 -0700
Message-ID: <4F23E557A0317D45864097982DE907941A3383@pilotmail.sbscorp.sbs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adam Anthony <AAnthony@sbs.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthias-Christian Ott <matthias.christian@tiscali.de>,
        Alexey Dobriyan <adobriyan@mail.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thank you for the heads up A&M.  I have destroyed the evil [^M]'s, and
updated the package.
http://prdownloads.sourceforge.net/sbs520lnxdrv/sbs520patch.bz2?download
-AA


-----Original Message-----
From: Matthias-Christian Ott [mailto:matthias.christian@tiscali.de] 
Sent: Monday, January 10, 2005 12:26 PM
To: Alexey Dobriyan
Cc: Adam Anthony; netdev@oss.sgi.com; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] /driver/net/wan/sbs520

Alexey Dobriyan wrote:

>On Mon, 10 Jan 2005 07:46:52 -0700, Adam Anthony wrote:
>
>  
>
>>With the permission of my employer, SBS Technologies, Inc., I have
>>released a patch for 2.4 kernels that supports the 520 Series of WAN
>>adapters.
>>    
>>
>
>My editor shows ^M at the end of every line of new
Documentation/Configure.help,
>MAINTAINERS (add ~63400 bogus lines!). Please, look at the patch _after_
>generating it.
>
>  
>
>>+obj-$(CONFIG_LANMEDIA)		+=		syncppp.o^M
>>    
>>
>
>  
>
>>+subdir-$(CONFIG_LANMEDIA) += lmc^M
>>    
>>
>
>Also random ^M's.
> 
>--- linux-2.4.28-virgin/drivers/net/wan/sbs520/lnxosl.c
>+++ /usr/src/linux-2.4.28/drivers/net/wan/sbs520/lnxosl.c
>
>  
>
>>+// Programming Language:	C^M
>>+// Target Processor:		Any^M
>>+// Target Operating System: Linux^M
>>    
>>
>
>Well, this is pretty obvious to everyone here. :-)
>
>  
>
>>+// This software may be used and distributed according to the terms^M
>>+// of the GNU General Public License, incorporated herein by reference.^M
>>    
>>
>
>Stupid question: do you mean GPL version 2 or something else?
>
>	Alexey
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>
>  
>
That's ugly, that are Microsoft line endings.

Matthias-Christian Ott

***This message has been scanned for virus, spam, and undesirable
content.***
***For further information, contact your mail administrator.***

For limitations on the use and distribution of this message, please visit www.sbs.com/emaildisclaimer.
