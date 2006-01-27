From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [-mm patch] drivers/net/wireless/tiacx/: remove code for WIRELESS_EXT < 18
Date: Fri, 27 Jan 2006 12:19:24 +0200
Message-ID: <200601271219.24332.vda@ilport.com.ua>
References: <20060122171104.GC10003@stusta.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Adrian Bunk <bunk@stusta.de>, acx100-devel@lists.sourceforge.net
In-Reply-To: <20060122171104.GC10003@stusta.de>
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

Hi Adrian,


On Sunday 22 January 2006 19:11, Adrian Bunk wrote:
> WIRELESS_EXT < 18 will never be true in the kernel.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Please don't do this. We are not in the kernel yet.

acx currently is in -mm, not in mainline.

We have quite a few users of it which aren't using -mm,
but instead compile it out-of-kernel.

We gradually removed 2.4 compat code and most of early 2.6isms.
Even that produced a few complains. Currently out-of-tree acx
is working for any kernel >= 2.6.10.

I very much want to get rid of all remaining compat cruft, and
I plan to do it as soon as acx will be present in mainline kernel.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
