From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [-mm patch] drivers/net/wireless/tiacx/: remove code for WIRELESS_EXT < 18
Date: Fri, 27 Jan 2006 14:49:49 +0200
Message-ID: <200601271449.49226.vda@ilport.com.ua>
References: <20060122171104.GC10003@stusta.de> <200601271219.24332.vda@ilport.com.ua> <1138362557.5983.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, acx100-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965014AbWA0MvR@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1138362557.5983.26.camel@localhost>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 January 2006 13:49, Johannes Berg wrote:
> On Fri, 2006-01-27 at 12:19 +0200, Denis Vlasenko wrote:
> 
> > I very much want to get rid of all remaining compat cruft, and
> > I plan to do it as soon as acx will be present in mainline kernel.
> 
> I doubt you'll get it merged with the compat cruft.

What cruft? This?

# grep -r WIRELESS_EXT .
./pci.c:                ndev->name, WIRELESS_EXT, UTS_RELEASE);
./common.c:             "Wireless extension version:\t" STRING(WIRELESS_EXT) "\n"
./acx_struct.h:#ifdef WIRELESS_EXT
./acx_struct.h:#if WIRELESS_EXT > 15
./ioctl.c:      range->we_version_compiled = WIRELESS_EXT;

I consider this to be a really modest amount of compat code
which makes driver users happy (that fraction of it which is not
willing to run -mm).

However, I would remove even that at Jeff's or Andrew's request,
or without anyone's request if acx will be merged to Linus tree.
--
vda
