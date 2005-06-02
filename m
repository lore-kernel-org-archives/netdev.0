From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.12-rc5-mm2: "bic unavailable using TCP reno" messages
Date: Thu, 2 Jun 2005 14:15:11 +0200
Message-ID: <20050602121511.GE4992@stusta.de>
References: <20050601022824.33c8206e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261387AbVFBMPT@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, shemminger@osdl.org
Content-Disposition: inline
In-Reply-To: <20050601022824.33c8206e.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2005 at 02:28:24AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.12-rc5-mm1:
>...
> +tcp-tcp_infra.patch
>...
>  Steve Hemminger's TCP enhancements.
>...

I said "no" to CONFIG_TCP_CONG_BIC, and now my syslog is full of messages
   kernel: bic unavailable using TCP reno

I have no problem with such a message being shown once - but once should 
be enough.  

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
