From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: 2.6.16-rc1-mm4: ACX=y, ACX_USB=n compile error
Date: Tue, 31 Jan 2006 09:54:36 -0500
Message-ID: <20060131145431.GI5433@tuxdriver.com>
References: <20060130133833.7b7a3f8e@zwerg> <200601310810.33107.vda@ilport.com.ua> <20060131100330.2931cbe9@zwerg> <200601311416.05397.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gabriel C." <crazy@pimpmylinux.org>, da.crew@gmx.net,
	linux-kernel@vger.kernel.org, Adrian Bunk <bunk@stusta.de>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750917AbWAaO4o@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200601311416.05397.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2006 at 02:16:05PM +0200, Denis Vlasenko wrote:

> CONFIG_ACX=y
> # CONFIG_ACX_PCI is not set
> # CONFIG_ACX_USB is not set
> 
> This won't fly. You must select at least one.
> 
> Attached patch will check for this and #error out.
> Andrew, do not apply to -mm, I'll send you bigger update today.

Is there any way to move this into a Kconfig file?  That seems nicer
than having #ifdefs in source code to check for a configuration error.

John

P.S.  Please post any patches with formatting according to kernel
conventions:

	http://linux.yyz.us/patch-format.html

-- 
John W. Linville
linville@tuxdriver.com
