From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] TNETW1450: successful device initialization
Date: Wed, 1 Feb 2006 11:20:15 +0200
Message-ID: <200602011120.15686.vda@ilport.com.ua>
References: <20060201085205.GA9315@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: andi@lisas.de
In-Reply-To: <20060201085205.GA9315@rhlx01.fht-esslingen.de>
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

On Wednesday 01 February 2006 10:52, Andreas Mohr wrote:
> Hi all,
> 
> - add initial support for new TNETW1450 USB chip (available on the market since
>   June or so): successful firmware booting, driver initialization working up to
>   a working iwconfig. Any network traffic whatsoever NOT working yet.
>   VERY EXPERIMENTAL! (especially since TNETW1450 sometimes uses enhanced,
>   longer structs for some IEs)
> - add a ton of different TNETW1450 USB device VID/PID combinations; it's
>   highly likely that there will be many more TNETW1450 devices in the future...
> - add many more firmware command IEs
> - firmware upload cleanup (rename variables to better names, unify the various
>   firmware upload implementations, ...)
> - add FIXME comment to remind about semaphore -> mutex conversion

Applied, mega thanks!

Do you have a "HOWTO sniff USB under Windows" or URL to it?
May be helpful for other potential developers.

> The TNETW1450 firmware image is currently called acx111usbcRR, with RR being
> the currently used radio ID 0x1b ("1b"): acx111usbc1b.

Patch actually says "tiacx..." which is what you obviously intended.

> NOTE that DWL-120+ firmware image - due to unified firmware name creation -
> now has a different name, too:
> acx100usbc0d! (Denis, simply revert it if you're offended by this change).

No objections, only changed that to _uppercase_ hex radio id
("tiacx111usbc1D") in order to match PCI firmware name convention.

> Total driver size increase: less than 2kB!

Wonderful
 
> ACX100 mini-PCI, DWL-120+ and TNETW1450 are all still working as before.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
