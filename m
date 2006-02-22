From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: From: Carlos   Mart??n <carlos@cmartin.tk>
Date: Wed, 22 Feb 2006 16:06:30 +0100
Message-ID: <200602221606.30837.carlos@cmartin.tk>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <200602212203.58216.carlos@cmartin.tk> <20060222143604.GA16269@infradead.org>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060222143604.GA16269@infradead.org>
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

On Wednesday 22 February 2006 15:36, Christoph Hellwig wrote:
> On Tue, Feb 21, 2006 at 10:03:58PM +0100, Carlos Mart?n wrote:
> > > The important bit is that you need the pointers with the above module
> > > spit, because you can't call usb- or pci-specific routines from=20
> > > acx-common.ko=20
> >=20
> > Yes, I realise that (unless you export them, but I don't think we want=
=20
that).=20
>=20
> even that wouldn't work with current module because the usb and pci modul=
es
> call into the common code and thus we'd have recursive module depency.

And you may not build both modules, so acx-common.ko would never be satisfi=
ed.=20
=46unction pointers all the way then.

>=20
> > This approach is probably better even if the driver is unified. Pointer=
=20
> > dereferences are cheaper than branches/jumping, aren't they?
>=20
> It shouldn't matter these days as cpus have nice branch prediction.

I remember reading P4s have problems with this because they had really long=
=20
branch pipes (the proper name escapes me at the moment) and if they got it=
=20
wrong, it took quite a bit of time (in CPU terms, of course) to flush them.=
 I=20
don't use them personally, but I believe the trend is to do that.

   cmn
=2D-=20
Carlos Mart=EDn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
