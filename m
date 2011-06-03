From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm: mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Thu, 02 Jun 2011 20:58:03 -0400
Message-ID: <5203.1307062683@turing-police.cc.vt.edu>
References: <1306922913-17803-1-git-send-email-metze@samba.org> <1306922913-17803-2-git-send-email-metze@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local> <1307053743.21633.22.camel@dcbw.foobar.com>
            <1307054132.21633.25.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1307062683_2826P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Alexey ORISHKO <alexey.orishko@stericsson.com>,
	Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:45300 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab1FCA6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 20:58:38 -0400
In-Reply-To: Your message of "Thu, 02 Jun 2011 17:35:31 CDT."
             <1307054132.21633.25.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1307062683_2826P
Content-Type: text/plain; charset=us-ascii

On Thu, 02 Jun 2011 17:35:31 CDT, Dan Williams said:
> On Thu, 2011-06-02 at 17:29 -0500, Dan Williams wrote:
> > On Wed, 2011-06-01 at 12:20 +0200, Alexey ORISHKO wrote:
> > > > -----Original Message-----
> > > > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > > > owner@vger.kernel.org] On Behalf Of Stefan Metzmacher
> > > > Sent: Wednesday, June 01, 2011 12:09 PM
> > > 
> > > 
> > > > -	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
> > > > +	.flags = FLAG_WWAN | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
> > > 
> > > This patch will introduce incompatibility with already existing
> > > applications, which track usbX devices. As a result, end user
> > > application will stop working.

I'm interpreting this as "devices which currently often get named usbX by udev,
and currently have FLAG_POINTTOPOINT set".  People are getting hung up
on the usbX part, not what the *real* problem is.

> A follow-on to this is that if you really care about specific devices,
> your application can use udev rules to "tag" specific interfaces based
> on USB VID/PID/GUID or other device attributes, and check for those tags
> in your program.  Use udev (good) or netlink (good) or SIOCGIFCONF (bad)
> to enumerate the various network interfaces on the system and pick the

I think Alexey's point was that the patch will hose up programs that
currently do the netlink or  SIOCGIFCONF thing and look for FLAG_POINTTOPOINT.

--==_Exmh_1307062683_2826P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFN6DGbcC3lWbTT17ARAkF8AJ0V4sNPAGtfzochn9YOiESfVr2pyQCg7T3G
ad/XKV6nkoGyoOp07qe5xFI=
=Qr1U
-----END PGP SIGNATURE-----

--==_Exmh_1307062683_2826P--

