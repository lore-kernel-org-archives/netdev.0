From: Alex Dubov <oakad@yahoo.com>
Subject: Re: [Bugme-new] [Bug 13692] New: dccp_ipv4 has >1 usage count and cannot be removed
Date: Sat, 4 Jul 2009 00:58:54 -0700 (PDT)
Message-ID: <474687.88131.qm@web37607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, dccp@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37607.mail.mud.yahoo.com ([209.191.87.90]:30295 "HELO
	web37607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753120AbZGDIFd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jul 2009 04:05:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Fri, 7/3/09, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:

> Date: Friday, July 3, 2009, 12:41 PM
> | > http://bugzilla.kernel.org/show_bug.cgi?id=3D13692
> | >=20
> | >=A0 =A0 =A0 =A0 =A0 =A0 Summary:
> dccp_ipv4 has >1 usage count and cannot be removed
> <snip>
> | >=20
> | > Upon loading of dccp_ipv4 (either through autoload
> or explicitly, with
> | > modprobe) the usage count of the module is
> immediately set to 2 and the module
> | > can not be unloaded.
> | >=20
> | > Usage count seems to be correctly
> incremented/decremented during operation, but
> | > never gets lower than 2.
> | >=20
>=20
> I believe that the current state provides some protection
> against
> accidental/unwanted removal by unsuspecting users. Arnaldo,
> what
> do you think?
>=20

Well, I tried "rmmod -f" first thing after noticing this behavior
and got a kernel crash dump immediately.

I'm not near that machine currently, but I'll post the crash dump on
Monday.



     =20
