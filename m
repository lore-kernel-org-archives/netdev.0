From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 11:56:25 +0200
Message-ID: <49FEBBC9.9000708@cosmosbay.com>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org> <49FE9999.7090103@redhat.com> <20090504095300.GF23223@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, Elad Lahav <elahav@uwaterloo.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43528 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513AbZEDKAn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 06:00:43 -0400
In-Reply-To: <20090504095300.GF23223@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :

>>> Or perhaps simple send to a local multicast group and let
>>> some netfilter module turn that into regular UDP.
>>> =20
>> Sounds hacky and rooty.
>=20
> rooty? Everyone can send to all directions anyways.
>=20
> It wouldn't be perfect, but quite usable as a short term solution
> for a production server.

Anyway, a netfilter module doesnt fit the needs (separate header/footer
for each destination)


