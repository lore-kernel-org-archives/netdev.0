From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/1] ipw2100: remove by-hand function entry/exit debugging
Date: Tue, 06 Sep 2005 21:51:21 -0400
Message-ID: <431E4799.7000502@pobox.com>
References: <200509062056.j86KuHcL031448@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, ipw2100-admin@linux.intel.com, pavel@suse.cz,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751193AbVIGBvi@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <200509062056.j86KuHcL031448@shell0.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Pavel Machek <pavel@ucw.cz>
> 
> This removes debug prints from entry/exit of functions.  Such level of
> debugging should probably be done by gdb or similar.
> 
> Signed-off-by: Pavel Machek <pavel@suse.cz>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

NAK.  Rationale:  maintainer's choice.  Pavel doesn't get to choose the 
debugger of choice for the driver maintainer.

I do this entry/exit stuff in my net and SATA drivers; printk is my 
primary method of debugging.

	Jeff
