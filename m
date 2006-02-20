From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: From: Carlos =?koi8-r?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Date: Mon, 20 Feb 2006 17:30:20 +0200
Message-ID: <200602201730.20908.vda@ilport.com.ua>
References: <11403021213131-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Carlos Martin <carlos@cmartin.tk>, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <11403021213131-git-send-email-carlos@cmartin.tk>
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

On Sunday 19 February 2006 00:35, Carlos Martin wrote:
> [PATCH] acxsm: Fix Kconfig option check
> 
> This check never actually worked because CONFIG_ACX_{ACX,USB} are
> tristate. With Adrian Bunk's patch to the Kconfig, this works with the
> _BOOL hidden Kconfig options.
> Also update error message adding that this shouldn't happen anymore.

Carlos, I didn't apply Adrian's patch to my tree.

I am not sure we want to support every imaginable .config.
Realistic goal is:
* allnoconfig must compile
* allyesconfig must compile
* allmodconfig must compile

Adrian's patch makes code more obfuscated and it still has one
corner case (when one choice is 'y' and other is 'm')

If you disagree, please explain why do you want Adrian's patch
applied.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
