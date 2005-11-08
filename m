From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [2.6 patch] airo.c/airo_cs.c: correct prototypes
Date: Tue, 8 Nov 2005 10:13:44 -0800
Message-ID: <20051108181344.GC14907@kroah.com>
References: <20051105164227.GK5368@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Benjamin Reed <breed@users.sourceforge.net>,
	linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965262AbVKHSQf@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051105164227.GK5368@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 05, 2005 at 05:42:27PM +0100, Adrian Bunk wrote:
> This patch creates a file airo.h containing prototypes of the global 
> functions in airo.c used by airo_cs.c .
> 
> If you got strange problems with either airo_cs devices or in any other 
> completely unrelated part of the kernel shortly or long after a airo_cs 
> device was detected by the kernel, this might have been caused by the 
> fact that caller and callee disagreed regarding the size of the first 
> argument to init_airo_card()...
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

queued to -stable.

thanks,

greg k-h
