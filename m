From: 'Ignacy Gawedzki' <ignacy.gawedzki@green-communications.fr>
Subject: Re: [PATCH net 1/2] gen_stats.c: Duplicate xstats buffer for later
 use
Date: Thu, 8 Jan 2015 13:32:35 +0100
Message-ID: <20150108123235.GB7223@zenon.in.qult.net>
References: <20150108103518.GA7214@zenon.in.qult.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC359A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:54250 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbbAHMdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 07:33:15 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC359A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 12:26:17PM +0000, thus spake David Laight:
> Looking at this again, isn't the purpose of the 'void *st' to pass
> down a temporary buffer that is 'big enough' ?

The buffer is large enough at the time of the call, yes.  But the thing=
 is
that in most of the actual callers, it is an automatic variable in the
caller's frame, while the buffer is actually used at a later point when
gnet_stats_finish_copy() is called (when that frame doesn't exist anymo=
re).

I'm about to send a revised version of the patch that also corrects a f=
ew
shortcomings in the management of the dynamically allocated buffer w.r.=
t. the
acquired lock.

Ignacy

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
