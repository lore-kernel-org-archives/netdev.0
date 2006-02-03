From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acx: make firmware statistics parsing more intelligent
Date: Fri, 3 Feb 2006 15:28:29 +0200
Message-ID: <200602031528.29945.vda@ilport.com.ua>
References: <20060203105857.GB11173@rhlx01.fht-esslingen.de> <200602031439.14467.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200602031439.14467.vda@ilport.com.ua>
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

On Friday 03 February 2006 14:39, Denis Vlasenko wrote:
> Well, gcc obviously failed to realize that "% 16" == "& 15".
> I'll file a bug.

-ENOTABUG. It's incorrect for signed integers,
and gcc uses idiv insn instead.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
