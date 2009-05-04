From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 4 May 2009 12:18:14 +0200
Message-ID: <20090504101814.GG23223@one.firstfloor.org>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org> <49FE9999.7090103@redhat.com> <20090504095300.GF23223@one.firstfloor.org> <49FEBBC9.9000708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Avi Kivity <avi@redhat.com>,
	Elad Lahav <elahav@uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41194 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbZEDKNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 06:13:39 -0400
Content-Disposition: inline
In-Reply-To: <49FEBBC9.9000708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 04, 2009 at 11:56:25AM +0200, Eric Dumazet wrote:
> Andi Kleen a =E9crit :
>=20
> >>> Or perhaps simple send to a local multicast group and let
> >>> some netfilter module turn that into regular UDP.
> >>> =20
> >> Sounds hacky and rooty.
> >=20
> > rooty? Everyone can send to all directions anyways.
> >=20
> > It wouldn't be perfect, but quite usable as a short term solution
> > for a production server.
>=20
> Anyway, a netfilter module doesnt fit the needs (separate header/foot=
er
> for each destination)

netfilter modues can create new skbs that reference the main data and r=
eplace=20
the header.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
