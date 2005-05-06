From: Domen Puncer <domen@coderock.org>
Subject: Re: [PATCH] dynamic wep keys for airo.c
Date: Fri, 6 May 2005 10:04:15 +0200
Message-ID: <20050506080415.GD3917@nd47.coderock.org>
References: <200505030826.42564.breed@zuzulu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261167AbVEFIEg@vger.kernel.org>
To: Benjamin Reed <breed@zuzulu.com>
Content-Disposition: inline
In-Reply-To: <200505030826.42564.breed@zuzulu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/05 08:26 -0700, Benjamin Reed wrote:
>  module_param_array(ssids, charp, NULL, 0);
>  module_param(auto_wep, int, 0);
> +module_param(perm_key_support, int, 1);

				       ^ permissions in sysfs

>   if (rc!=SUCCESS) printk(KERN_ERR "airo:  WEP_TEMP set %x\n", rc);
>   if (perm) {
> +  // We make these messages debug. They really should be error,
> +  // but no one seems to use the TEMP flag and writing a PERM key
> +  // with the MAC disable throws this error

/* */?


	Domen
