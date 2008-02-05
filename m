From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: Re: [e1000][net-2.6 tree] Regression: driver doesn't
 detect card on my node.
Date: Tue, 05 Feb 2008 09:43:00 -0800
Message-ID: <200802050943.01652.yinghai.lu@sun.com>
References: <47A89A77.1050608@openvz.org> <47A89BC1.6080702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Thomas Gleixner <tglx@linutronix.de>, jeffrey.t.kirsher@intel.com,
	Denis Lunev <den@openvz.org>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	Justin Piszcz <jpiszcz@lucidpixels.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <47A89BC1.6080702@intel.com>
Content-disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tuesday 05 February 2008 09:24:17 am Kok, Auke wrote:
> 
> [Added Ingo, Thomas, Justin who signed off on the patch/tested it]
> 
> Pavel Emelyanov wrote:
> > The commit
> > 
> > 	093af8d7f0ba3c6be1485973508584ef081e9f93
> > 	x86_32: trim memory by updating e820
> > 
> > broke my e1000 card: on loading driver says that
> > 
> > 	e1000: probe of 0000:04:03.0 failed with error -5
> > 
> > and the interface doesn't appear.
> > 
> > With this commit reset everything is OK.
> > 
> > lspci output:
> > 04:03.0 Ethernet controller: Intel Corporation 82541GI Gigabit Ethernet Controller (rev 05)
> > lspci -n output:
> > 04:03.0 Class 0200: 8086:1076 (rev 05)
> > 
> > My colleague Denis Lunev has e1000 adapter too, but doesn't
> > experience such problems.
> > 
> > What other info from me is required?

boot log please. with the patch and reverting the patch.

Thanks

YH

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
