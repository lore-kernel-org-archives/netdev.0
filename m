From: Pascal de Bruijn <keizerflipje@home.nl>
Subject: Re: r8169 1.6LK lockup
Date: Fri, 03 Sep 2004 00:05:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41379937.5060301@home.nl>
References: <4137418D.2040706@home.nl> <20040902174437.GA12068@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040902174437.GA12068@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Right,
I've patched my kernel, and now everything works like a breeze...

I enabled all features:
ethtool -K eth0 rx on tx on sg on tso on

Then I uploaded 10GB and downloaded about 2GB (in an alternating style).

No more lockups...

Good work!

Thanks,
Pascal de Bruijn


Francois Romieu wrote:

>Pascal de Bruijn <keizerflipje@home.nl> :
>[francois messed the r8169 update]
>
>How does the system perform if you apply the patches below as well:
>http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc1-mm1/r8169-130.patch
>http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.9-rc1-mm1/r8169-140.patch
>
>Please Cc: netdev@oss.sgi.com
>
>--
>Ueimor
>
>  
>
