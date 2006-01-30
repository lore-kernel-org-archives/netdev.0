From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.16-rc1-mm4: ACX=y, ACX_USB=n compile error
Date: Mon, 30 Jan 2006 19:10:39 +0100
Message-ID: <20060130181039.GC3655@stusta.de>
References: <20060130133833.7b7a3f8e@zwerg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, da.crew@gmx.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751040AbWA3SKm@vger.kernel.org>
To: "Gabriel C." <crazy@pimpmylinux.org>,
	Denis Vlasenko <vda@ilport.com.ua>, linville@tuxdriver.com
Content-Disposition: inline
In-Reply-To: <20060130133833.7b7a3f8e@zwerg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2006 at 01:38:33PM +0100, Gabriel C. wrote:

> Hello,

Hi Gabriel,

> I got this compile error with 2.6.16-rc1-mm4 , config attached. 
> 
> 
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function
> `acx_l_transmit_authen1':common.c:(.text+0x6cd62): undefined reference
> to `acxusb_l_alloc_tx' :common.c:(.text+0x6cd74): undefined reference
> to `acxusb_l_get_txbuf' :common.c:(.text+0x6cdeb): undefined reference
> to `acxusb_l_tx_data' drivers/built-in.o: In function
> `acx_s_configure_debug': undefined reference to
> `acxusb_s_issue_cmd_timeo_debug' drivers/built-in.o: In function
> [many more]
>...

Thanks for your report.

@Denis:
The problem seems to be CONFIG_ACX=y, CONFIG_ACX_USB=n.

> Gabriel 

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
