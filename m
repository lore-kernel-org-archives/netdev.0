From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support Nokia Slim Modems
Date: Fri, 1 Oct 2010 12:20:52 +0300
Message-ID: <201010011220.53162.remi@remlab.net>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com> <201010011142.45767.remi@remlab.net> <20101001085553.GA27109@bnru01.bnr.st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"STEricsson_nomadik_linux" <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36278 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab0JAJU5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 05:20:57 -0400
In-Reply-To: <20101001085553.GA27109@bnru01.bnr.st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Hello,

On Friday 01 October 2010, Kumar SANGHVI wrote:
> Hi,
>=20
> On Fri, Oct 01, 2010 at 10:42:44 +0200, R=E9mi Denis-Courmont wrote:
> > > I have not introduced any new ioctl()'s as part of Pipe controlle=
r
> > > implementation.
> >=20
> > Sure. What you did is basically worse than ioctl()'s. You've implem=
ented
> > them as socket options. Socket options are meant to configure param=
eters
> > with setsockopt and read paramters with getsockopt. They are not me=
ant
> > for 'doing' things - that's what ioctl()'s are for.
>=20
> Isn't the existing phonet stack 'doing' something as part of
> PNPIPE_ENCAP rather than simply configuring some socket option or fla=
g ?

It sets (or gets) the delivery path for incoming data.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
