From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] WLAN acx100: OOPS fix, KERN_xxx, misc.
Date: Mon, 16 Jan 2006 16:34:21 +0200
Message-ID: <200601161634.21183.vda@ilport.com.ua>
References: <20060116140233.GA8170@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Andreas Mohr <andim2@users.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <20060116140233.GA8170@rhlx01.fht-esslingen.de>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Monday 16 January 2006 16:02, Andreas Mohr wrote:
> Hi all (and especially Denis),
> 
> acx-20060116_misc.diff:
> - fix OOPS in acx_l_rxmonitor() (wrong ndev->type setting leading to memcpy
>   of negative size) by reworking monitor mode type setup and adding
>   missing sanity checks
> - rename acx1XX_ie_powermgmt_t to more correct acx1XX_ie_powersave_t
> - fix format string compile warnings
> - add <linux/compiler.h> include apparently required for __iomem define
>   around Linux 2.6.8
> - rework eCPU init by replacing static msleep with faster, more intelligent
>   (hopefully) busy-wait
> 
> acx-20060116_KERN_xxx.diff (too large: gzipped):

Applied, thanks!

> - add proper KERN_xxx prefixes to printk() as requested recently

Please forward me that request.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
