From: Denis Vlasenko <vda@ilport.com.ua>
Subject: acxsm: migrate acx from homegrown 802.11 handling to softmac stack
Date: Sun, 15 Jan 2006 13:52:44 +0200
Message-ID: <200601151352.44548.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: netdev@vger.kernel.org, softmac-dev@sipsolutions.net,
	acx100-devel@lists.sourceforge.net
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

Hi,

http://195.66.192.167/linux/acx_patches/acxsm-20060115.tar.bz2

README says:
==================
*** Not run tested. Almost certainly won't work. Lots of things are TODO. ***

This tarball contains a port of acx driver to ieee80211softmac
stack. Broadcom 43xx driver was used as an example.
See http://bcm43xx.berlios.de/,
ftp://ftp.berlios.de/pub/bcm43xx/snapshots/

Latest softmac source is in softmac-snapshot/ and net/
is a symling to softmac-snapshot/include/net/.
softmac-snapshot/ is to be replaced regularly with newer
snapshots from http://softmac.sipsolutions.net/SoftMAC.

grep for '//SM' to see the code added to standalone acx driver code.
...
...
===================

This is it.

P.S. It does not mean that acx driver is discontinued.
It will be supported as before. Let's see whether acxsm
will get any traction at all.
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
