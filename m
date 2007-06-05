From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] bugfix GFP_KERNEL -> GFP_ATOMIC in
	spin_locked region
Date: Tue, 5 Jun 2007 10:51:39 +0200
Message-ID: <200706051051.40016.oneukum@suse.de>
References: <87odjvu1on.fsf@wanadoo.fr>
	<20070604210018.0eaa20a0.akpm@linux-foundation.org>
	<20070604210824.dfb7c2d9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sumant Patro <sumant.patro@lsi.com>,
	Yoann Padioleau <padator@wanadoo.fr>,
	linux-usb-devel@lists.sourceforge.net, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@lists.osdl.org, Seokmann Ju <seokmann.ju@lsil.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070604210824.dfb7c2d9.akpm@linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Am Dienstag, 5. Juni 2007 06:08 schrieb Andrew Morton:
> Everything in USB appears to already be fixed, apart from the io_ti.c bug.

Yes, that's a bug. I've queued a patch.

	Regards
		Oliver

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
