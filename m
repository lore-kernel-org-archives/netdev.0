From: Matt Mackall <mpm@selenic.com>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: Mon, 20 Dec 2004 13:14:19 -0800
Message-ID: <20041220211419.GC5974@waste.org>
References: <59719.192.102.214.6.1103214002.squirrel@webmail.wetlettuce.com> <20041216211024.GK2767@waste.org> <34721.192.102.214.6.1103274614.squirrel@webmail.wetlettuce.com> <20041217215752.GP2767@waste.org> <20041217233524.GA11202@electric-eye.fr.zoreil.com> <36901.192.102.214.6.1103535728.squirrel@webmail.wetlettuce.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261645AbULTVPF@vger.kernel.org>
To: Mark Broadbent <markb@wetlettuce.com>
Content-Disposition: inline
In-Reply-To: <36901.192.102.214.6.1103535728.squirrel@webmail.wetlettuce.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 20, 2004 at 09:42:08AM -0000, Mark Broadbent wrote:
> 
> Exactly the same happens, I still get a 'NMI Watchdog detected LOCKUP'
> with the r8169 device using the above patch on top of 2.6.10-rc3-bk10.

Ok, that suggests a problem localized to netpoll itself. Do you have
spinlock debugging turned on by any chance? 

-- 
Mathematics is the supreme nostalgia of our time.
