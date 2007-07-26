From: David Miller <davem@davemloft.net>
Subject: Re: net/bluetooth/rfcomm/tty.c: use-after-free
Date: Thu, 26 Jul 2007 00:12:50 -0700 (PDT)
Message-ID: <20070726.001250.18310187.davem@davemloft.net>
References: <20070723012543.GW26212@stusta.de>
	<1185176832.7111.32.camel@violet>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ville.tervo@nokia.com, maxk@qualcomm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bunk@stusta.de,
	bluez-devel@lists.sf.net
To: marcel@holtmann.org
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1185176832.7111.32.camel@violet>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 23 Jul 2007 09:47:12 +0200

> Hi Adrian,
> 
> > Commit 8de0a15483b357d0f0b821330ec84d1660cadc4e added the following 
> > use-after-free in net/bluetooth/rfcomm/tty.c:
 ...
> > Spotted by the Coverity checker.
> 
> really good catch. I fully overlooked that one. The attached patch
> should fix it.
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Applied, thanks everyone.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
