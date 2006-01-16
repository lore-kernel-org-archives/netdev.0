From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: Re: acxsm: migrate acx from homegrown 802.11 handling to softmac stack
Date: Mon, 16 Jan 2006 08:52:14 +0200
Message-ID: <200601160852.14702.vda@ilport.com.ua>
References: <200601151352.44548.vda@ilport.com.ua> <200601151929.43896.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <200601151929.43896.carlos@cmartin.tk>
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

On Sunday 15 January 2006 20:29, Carlos Mart=EDn wrote:
> On Sunday 15 January 2006 12:52, Denis Vlasenko wrote:
> > Hi,
> >=20
> > http://195.66.192.167/linux/acx_patches/acxsm-20060115.tar.bz2
>=20
> I've mirrored it at http://www.cmartin.tk/acx/ and will sync as with the=
=20
> 'normal' tarballs.
>=20
> >=20
> > README says:
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > *** Not run tested. Almost certainly won't work. Lots of things are TOD=
O.
>=20
> I'll try to try it out this week. Unfortunately, my USB device is broken=
=20
> again.

It's not ready for actual usage, but code review would be appreciated.
I am trying to keep acxsm close enough to acx so that "diff -urp acx acxsm"
will give good idea about the differences.

> > P.S. It does not mean that acx driver is discontinued.
> > It will be supported as before. Let's see whether acxsm
> > will get any traction at all.
>              at^^^^^^^^
> You mean it won't slip when the road is wet? :P
> This should make certain things easier to handle, won't it? From what I'v=
e=20
> seen you don't have to worry about fragmentation of packets. Will the sta=
ck=20
> also handle TKPI/WPA?

Stack is meant to eventually handle all bells and whistles.
The first important missing thing is AP mode. There is softmac'ish
AP mode implementation in Devicescape stack...
=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
