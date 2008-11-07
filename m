From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] phonet: sparse annotations of protocol, remove forward
 declaration
Date: Fri, 07 Nov 2008 12:02:01 -0800
Message-ID: <1226088121.11596.55.camel@brick>
References: <1226022793.5482.1.camel@brick>
	 <200811071041.41787.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:23249 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbYKGUCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 15:02:04 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1432127wfd.4
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 12:02:03 -0800 (PST)
In-Reply-To: <200811071041.41787.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-07 at 10:41 +0200, R=C3=A9mi Denis-Courmont wrote:
> On Friday 07 November 2008 03:53:13 ext Harvey Harrison, you wrote:
> > net/phonet/af_phonet.c:38:36: error: marked inline, but without a
> > definition
> > net/phonet/pep-gprs.c:63:10: warning: incorrect type in return=20
> > expression (different base types)
> > net/phonet/pep-gprs.c:63:10:    expected int
> > net/phonet/pep-gprs.c:63:10:    got restricted __be16 [usertype]
> > <noident>=20
> > net/phonet/pep-gprs.c:65:10: warning: incorrect type in return
> > expression=20
> > (different base types)
> > net/phonet/pep-gprs.c:65:10:    expected int=20
> > net/phonet/pep-gprs.c:65:10:    got restricted __be16 [usertype]
> > <noident>=20
> > net/phonet/pep-gprs.c:124:16: warning: incorrect type in assignment
> > (different base types)
> > net/phonet/pep-gprs.c:124:16:    expected restricted=20
> > __be16 [usertype] protocol
> > net/phonet/pep-gprs.c:124:16:    got unsigned short [unsigned]
> > [usertype] protocol=20
>=20
> Thanks. May I ask where the documentation to run these checks is?
>=20

You need to add the -D__CHECK_ENDIAN__ flag to sparse to enable these
checks.

make C=3D1 CF=3D-D__CHECK_ENDIAN__

should do the trick if you have sparse already.

Harvey

