From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver
 support
Date: Thu, 29 Jan 2015 18:20:24 -0500
Message-ID: <54CAC038.9000009@ti.com>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <54C9654C.8030407@ti.com> <54CA6C20.5090301@ti.com> <15828198.gHAJTouZOU@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Balbi, Felipe" <balbi-l0cyMroinI0@public.gmane.org>, <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <15828198.gHAJTouZOU@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/29/2015 05:00 PM, Arnd Bergmann wrote:
> On Thursday 29 January 2015 12:21:36 Murali Karicheri wrote:
>>
>> I think the solution is to make the cpsw_ale as a module and configured
>> through a Kconfig option. I am working on a fix for this now.
>>
>> Similar fix is required for cpts.o. Currently we are not using this
>> module for Netcp, but soon this will be re-used. I have send a patch
>> that is already applied to net-next removing cpts.o for Netcp.
>>
>
> Great, thanks a lot for the follow-up.
>
> 	Arnd
Arnd,

I have just posted a patch to nedev list to address this issue. Please 
review and let me know your comments. This also require some additional 
fixes in drivers/soc/ti/ to build them as modules as well. Santosh has 
queued them against next merge window.

Felipe, Mugunthan,

As the patch touches ti_cpsw as well, please review and provide your 
comments. It will be great if you can apply this patch on net-next 
branch and test it on ti platform using ti_cpsw driver.

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
