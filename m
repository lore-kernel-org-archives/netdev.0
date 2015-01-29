From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver
 support
Date: Thu, 29 Jan 2015 12:21:36 -0500
Message-ID: <54CA6C20.5090301@ti.com>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <54C92878.3030207@ti.com> <54C94A0D.9050505@ti.com> <20343006.1NmdQEM9nn@wuerfel> <54C9654C.8030407@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, "Balbi, Felipe" <balbi-l0cyMroinI0@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54C9654C.8030407-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/28/2015 05:40 PM, Murali Karicheri wrote:
> + Felipe, Mugunthan for commenting on TI_CPSW, ALE.
>

  --- Cut ------

>
>>
>> The second problem is where I got stuck myself: cpsw_ale.c (also cpts.c)
>> is getting linked into both modules, which is not allowed: It is
>> impossible for the kernel to compile these if one driver is a module
>> and the other one is not, and any use of KBUILD_MODNAME fails because
>> it is unclear what the modname is if the file is compiled once to
>> be linked into two drivers.
Arnd,

I think the solution is to make the cpsw_ale as a module and configured 
through a Kconfig option. I am working on a fix for this now.

Similar fix is required for cpts.o. Currently we are not using this 
module for Netcp, but soon this will be re-used. I have send a patch 
that is already applied to net-next removing cpts.o for Netcp.

Murali
>
> I am still looking into this. Both Keystone and TI CPSW driver would
> need to use cpsw_ale.o and cpts.o (currently not used, but will need
> this later). Not found a solution yet.
>
> Murali
>>
>> Arnd
>
>


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
