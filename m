From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] acx: make firmware statistics parsing more intelligent
Date: Wed, 8 Feb 2006 13:54:57 +0100
Message-ID: <20060208125456.GA6517@rhlx01.fht-esslingen.de>
References: <20060203105857.GB11173@rhlx01.fht-esslingen.de> <200602041331.16308.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200602041331.16308.vda@ilport.com.ua>
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

On Sat, Feb 04, 2006 at 01:31:16PM +0200, Denis Vlasenko wrote:
> On Friday 03 February 2006 12:58, Andreas Mohr wrote:
> > - use "% 8" modulo instead of more complicated "% 5" calculation
> 
> Why? There will be HZ=100 and HZ=250 boxes, 8ms doesn't fit well.
> 10ms is ok, 5ms or 2.5ms is more or less ok too, but 8ms?
> 
> But I'll apply this anyway.

Your objection is right, I think, since trading in a more "normal" scheduling
slice length for a *slight* gain in code size doesn't make too much sense.
So maybe still use "% 5"?

Sorry for the wasted discussion...

Andreas Mohr


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
