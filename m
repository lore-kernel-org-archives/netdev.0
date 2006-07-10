From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [2.6 patch] let BT_HIDP depend on INPUT
Date: Mon, 10 Jul 2006 21:07:20 +0200
Message-ID: <1152558440.32554.4.camel@localhost>
References: <20060710183154.GD13938@stusta.de>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux390@de.ibm.com,
	bluez-devel@lists.sf.net, maxk@qualcomm.com,
	linux-kernel@vger.kernel.org
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060710183154.GD13938@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Adrian,

> This patch let's BT_HIDP depend on instead of select INPUT.
> 
> This fixes the following warning during an s390 build:
> 
> <--  snip  -->
> 
> ...
> net/bluetooth/hidp/Kconfig:4:warning: 'select' used by config symbol 'BT_HIDP' refer to undefined symbol 'INPUT'
> ...
> 
> <--  snip  -->
> 
> A dependency on INPUT also implies !S390 (and therefore makes the 
> explicit dependency obsolete) since INPUT is not available on s390.
> 
> The practical difference should be nearly zero, since INPUT is always 
> set to y unless EMBEDDED=y (or S390=y).

I actually have no idea why we ended up with using select, but depends
is also fine by me. Except I like to see it "BT && BT_L2CAP && INPUT" ;)

Regards

Marcel




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
