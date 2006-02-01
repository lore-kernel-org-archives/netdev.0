From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] TNETW1450: successful device initialization
Date: Wed, 1 Feb 2006 10:29:43 +0100
Message-ID: <20060201092943.GA29096@rhlx01.fht-esslingen.de>
References: <20060201085205.GA9315@rhlx01.fht-esslingen.de> <200602011120.15686.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@lisas.de, acx100-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200602011120.15686.vda@ilport.com.ua>
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

Hi,

[noted that you CC'd netdev; I'd been wondering whether I should do that -
should really have done it myself...]

On Wed, Feb 01, 2006 at 11:20:15AM +0200, Denis Vlasenko wrote:
> Applied, mega thanks!
> 
> Do you have a "HOWTO sniff USB under Windows" or URL to it?
> May be helpful for other potential developers.
There's a page on the internet listing many different USB sniffers for
Windows. I don't have the URL handy right now, though, sorry.

> > The TNETW1450 firmware image is currently called acx111usbcRR, with RR being
> > the currently used radio ID 0x1b ("1b"): acx111usbc1b.
> 
> Patch actually says "tiacx..." which is what you obviously intended.
Uh, right.

> > NOTE that DWL-120+ firmware image - due to unified firmware name creation -
> > now has a different name, too:
> > acx100usbc0d! (Denis, simply revert it if you're offended by this change).
> 
> No objections, only changed that to _uppercase_ hex radio id
> ("tiacx111usbc1D") in order to match PCI firmware name convention.
Doh! I really wonder how that managed to escape me. Thanks for catching it!

> > Total driver size increase: less than 2kB!
> 
> Wonderful
I'm still expecting this to go up to perhaps 6kB increase, though.

Andreas Mohr


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
