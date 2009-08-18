From: Patrick McHardy <kaber@trash.net>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 15:01:49 +0200
Message-ID: <4A8AA63D.4000702@trash.net>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net> <4A8AA253.8090300@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57804 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbZHRNBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 09:01:50 -0400
In-Reply-To: <4A8AA253.8090300@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> LOCALLY GENERATED PACKET, hogs CPU
> ----------------------------------
>=20
> IN=3D OUT=3Deth1 SRC=3D10.252.5.1 DST=3D239.255.12.42 LEN=3D1344
> TOS=3D0x00 PREC=3D0x00 TTL=3D8 ID=3D41664 DF PROTO=3DUDP SPT=3D47920
> DPT=3D1234 LEN=3D1324 UID=3D1007 GID=3D1007
>     1. raw:OUTPUT
>     2. mangle:OUTPUT
>     3. filter:OUTPUT
>     4. mangle:POSTROUTING
>=20

Please include the complete output, I need to see the devices logged
at each hook.
