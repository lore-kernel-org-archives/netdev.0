From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: From: Carlos =?utf-8?q?Mart=D1=86=E2=95=9Cn?= <carlos@cmartin.tk>
Date: Mon, 20 Feb 2006 19:56:07 +0100
Message-ID: <200602201956.07340.carlos@cmartin.tk>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <200602201730.20908.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200602201730.20908.vda@ilport.com.ua>
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

On Monday 20 February 2006 16:30, Denis Vlasenko wrote:
> On Sunday 19 February 2006 00:35, Carlos Martin wrote:
> > [PATCH] acxsm: Fix Kconfig option check
> >=20
> > This check never actually worked because CONFIG_ACX_{ACX,USB} are
> > tristate. With Adrian Bunk's patch to the Kconfig, this works with the
> > _BOOL hidden Kconfig options.
> > Also update error message adding that this shouldn't happen anymore.
>=20
> Carlos, I didn't apply Adrian's patch to my tree.
>=20
> I am not sure we want to support every imaginable .config.
> Realistic goal is:
> * allnoconfig must compile
> * allyesconfig must compile
> * allmodconfig must compile
Which doesn't work with your #error condition.

>=20
> Adrian's patch makes code more obfuscated and it still has one
> corner case (when one choice is 'y' and other is 'm')
>=20
> If you disagree, please explain why do you want Adrian's patch
> applied.

It at least compiles. Your tree doesn't compile. It always tells me that I=
=20
didn't choose either USB or PCI support which is incorrect.

I've just tested this and CONFIG_ACX_{PCI,USB} only get defined if they are=
=20
set to Y. If they're set to M, it doesn't, so it spews out the warning.

I don't like Adrian's patch, and I don't think it's the right way to do it,=
=20
but it's what we have that works. I'll try to think of something a bit more=
=20
elegant meanwhile.

   cmn
=2D-=20
Carlos Mart=EDn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
