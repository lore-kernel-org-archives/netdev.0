From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] acx: make firmware statistics parsing more intelligent
Date: Fri, 3 Feb 2006 14:56:03 +0100
Message-ID: <20060203135603.GA19965@rhlx01.fht-esslingen.de>
References: <20060203105857.GB11173@rhlx01.fht-esslingen.de> <200602031439.14467.vda@ilport.com.ua> <200602031528.29945.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200602031528.29945.vda@ilport.com.ua>
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

On Fri, Feb 03, 2006 at 03:28:29PM +0200, Denis Vlasenko wrote:
> On Friday 03 February 2006 14:39, Denis Vlasenko wrote:
> > Well, gcc obviously failed to realize that "% 16" == "& 15".
> > I'll file a bug.
> 
> -ENOTABUG. It's incorrect for signed integers,
> and gcc uses idiv insn instead.

...which is one of the performance reasons why it may be a good idea
to use unsigned ints wherever signedness isn't required (unsigned int
is said to be faster sometimes, on many platforms).

Andreas Mohr


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
