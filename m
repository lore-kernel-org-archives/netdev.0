From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Sun, 09 Jul 2006 09:34:21 +0200
Message-ID: <44B0B17D.10803@tungstengraphics.com>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com>
	<44AE8CBB.4070409@better.se>
	<44AFDA3B.6020904@tungstengraphics.com>
	<44B0AED8.3040604@better.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net,
	Alan Hourihane <alanh@tungstengraphics.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <dri-devel-bounces@lists.sourceforge.net>
To: Marcus Better <marcus@better.se>
In-Reply-To: <44B0AED8.3040604@better.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: dri-devel-bounces@lists.sourceforge.net
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Marcus Better wrote:

>It appears to be on a different IRQ:
>~$ cat /proc/interrupts
>           CPU0
>  0:     202574          XT-PIC  timer
>  1:       2649          XT-PIC  i8042
>  2:          0          XT-PIC  cascade
>  8:          0          XT-PIC  rtc
>  9:          0          XT-PIC  acpi
> 10:       1059          XT-PIC  yenta, Intel 82801CA-ICH3 Modem, Intel
>82801CA-ICH3
> 11:      40776          XT-PIC  uhci_hcd:usb1, uhci_hcd:usb2, eth0
> 12:     100433          XT-PIC  i8042
> 14:      63563          XT-PIC  ide0
> 15:       6773          XT-PIC  ide1
>NMI:          0
>ERR:          0
>
>(This is without i915 loaded though.)
>
>  
>
Strange. I've also seen the i915 sending false interrupts on its own 
line, though.

Does the "noirqdebug" option fix the problem?

/Thomas



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--
