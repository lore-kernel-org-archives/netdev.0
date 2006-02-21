From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: Re: From: Carlos =?utf-8?q?Mart=D1=86=E2=95=9Cn?= <carlos@cmartin.tk>
Date: Tue, 21 Feb 2006 15:31:58 +0100
Message-ID: <200602211531.58821.carlos@cmartin.tk>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <200602201956.07340.carlos@cmartin.tk> <200602210817.19138.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200602210817.19138.vda@ilport.com.ua>
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

On Tuesday 21 February 2006 07:17, Denis Vlasenko wrote:
>=20
> allmodconfig for acx is:
>=20
> CONFIG_ACX=3Dm
> CONFIG_ACX_PCI=3Dy
> CONFIG_ACX_USB=3Dy
>=20
> and it compiles for me just fine. Please send me your .config.
> Mine is attached.

My bad, sorry. I forgot to copy the Kconfig file over, so I was getting=20
tristate ACX_{PCI,USB} instead of bools.

I had

CONFIG_ACX=3Dm
CONFIG_ACX_PCI=3Dm
CONFIG_ACX_PCI_BOOL=3Dy
CONFIG_ACX_USB=3Dm
CONFIG_ACX_USB_BOOL=3Dy

So of course it was failing. Once I copied Kconfig over, all goes according=
 to=20
plan.

   cmn
=2D-=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
