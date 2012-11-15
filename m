From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: Latest 3.6.6 are not compiling due tg3 network driver,
 hwmon_device_unregister
Date: Wed, 14 Nov 2012 19:24:29 -0800
Message-ID: <50A4606D.4020402@broadcom.com>
References: <8b566c4a9ee622737212dc17291ee238@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Denys Fedoryshchenko" <denys@visp.net.lb>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8b566c4a9ee622737212dc17291ee238@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was fixed by

commit de0a41484c47d783dd4d442914815076aa2caac2
Author: Paul Gortmaker <paul.gortmaker@windriver.com>
Date:   Mon Oct 1 11:43:49 2012 -0400

     tg3: unconditionally select HWMON support when tg3 is enabled.


Nithin.


On 11/14/2012 07:03 PM, Denys Fedoryshchenko wrote:
> Hi
>
> During compiling i am getting that:
>
> drivers/built-in.o: In function `tg3_close':
> tg3.c:(.text+0x12902e): undefined reference to `hwmon_device_unregister'
> drivers/built-in.o: In function `tg3_hwmon_open':
> tg3.c:(.text+0x12ae09): undefined reference to `hwmon_device_register'
>
> Kernel config are at http://nuclearcat.com/config-tg3.txt  , but i noticed this error are 
> appearing at x86, x64 kernels, probably also other 3.6.x series kernels.
> Disabling TG3 driver helps, but i believe it is not a solution.
>
> ---
> Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
