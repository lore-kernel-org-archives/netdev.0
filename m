From: Phil Sutter <phil.sutter@viprinet.com>
Subject: Re: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Fri, 2 Sep 2011 15:59:55 +0200
Message-ID: <20110902135954.GA29025@philter>
References: <20110505141107.GC30443@orbit.nwl.cc>
 <1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
 <1314971179.3092.159.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vipri.net ([89.207.250.2]:46771 "EHLO mail.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224Ab1IBOAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 10:00:12 -0400
Content-Disposition: inline
In-Reply-To: <1314971179.3092.159.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2011 at 02:46:17PM +0100, Ben Hutchings wrote:
> On Fri, 2011-09-02 at 13:08 +0200, Phil Sutter wrote:
> > This flushes the cache before and after accessing the mmapped packe=
t
> > buffer. It seems like the call to flush_dcache_page from inside
> > __packet_get_status is not enough on Kirkwood (or ARM in general).
> > ---
> > I know this is far from an optimal solution, but it's in fact the o=
nly working
> > one I found.
> [...]
>=20
> This is ridiculous.  If flush_dcache_page() isn't doing everything it
> should, you need to fix that.

You're absolutely correct. But in fact this problem goes way too deep
for me to find it's cause. And since my time is finite, I doubt this
will change in the near future. So I asked for help, a pointer in
whatever direction or anything I could try to help further analyzing -
without any response (unless I missed it, in which case I apologize).

Please don't get me wrong. I have no intend in this patch becoming
mainline, just want to give others with the same problem a starting
point.

Greetings, Phil
--=20
Viprinet GmbH
Mainzer Str. 43
55411 Bingen am Rhein
Germany

Zentrale:     +49-6721-49030-0
Durchwahl:    +49-6721-49030-134
=46ax:          +49-6721-49030-209

phil.sutter@viprinet.com
http://www.viprinet.com

Sitz der Gesellschaft: Bingen am Rhein
Handelsregister: Amtsgericht Mainz HRB40380
Gesch=C3=A4ftsf=C3=BChrer: Simon Kissel
