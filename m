From: Daniel Drake <dsd@gentoo.org>
Subject: Re: zd1211rw regression, device does not enumerate
Date: Fri, 31 Aug 2007 23:21:21 -0400
Message-ID: <46D8DAB1.3090503@gentoo.org>
References: <200708310958.38132.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-usb-devel@lists.sourceforge.net,
	"John W.Linville" <linville@tuxdriver.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200708310958.38132.oliver@neukum.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> after bisection it boils down to this patch:
> 
> oliver@oenone:/home/olli2/Trees/linux-2.6> git bisect bad
> 74553aedd46b3a2cae986f909cf2a3f99369decc is first bad commit
> commit 74553aedd46b3a2cae986f909cf2a3f99369decc
> Author: Daniel Drake <dsd@gentoo.org>
> Date:   Sun Jul 1 18:22:32 2007 +0100
> 
>     [PATCH] zd1211rw: Defer firmware load until first ifup
> 
> that plugging in my device I get an error:
> Aug 16 13:17:11 oenone kernel: zd1211rw 3-4.3:1.0: zd1211b chip 0ace:1215 v4810 high 00-02-72 AL2230_RF pa0 g--NS
> Aug 16 13:17:12 oenone ifup: Cannot enable interface eth2.

Can you enable CONFIG_ZD1211RW_DEBUG and post new logs?

Would also be nice to have a bug on the kernel bugzilla to track this.

Thanks,
Daniel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
