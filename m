From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 12:19:09 -0400
Message-ID: <20110720161909.GH12349@hmsreliant.think-freely.org>
References: <1311108107.3113.22.camel@edumazet-laptop>
 <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop>
 <4E2626E1.6030005@candelatech.com>
 <20110720020737.GB2692@neilslaptop.think-freely.org>
 <1311135855.3113.66.camel@edumazet-laptop>
 <20110720151827.GD12349@hmsreliant.think-freely.org>
 <1311175817.2338.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110720153958.GE12349@hmsreliant.think-freely.org>
 <1311176688.2338.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58852 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343Ab1GTQTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 12:19:16 -0400
Content-Disposition: inline
In-Reply-To: <1311176688.2338.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 05:44:48PM +0200, Eric Dumazet wrote:
> Le mercredi 20 juillet 2011 =E0 11:39 -0400, Neil Horman a =E9crit :
>=20
> > Isn't that exactly what this does?  Disallows a user from issuing t=
he cone_skb
> > command in a pktgen script if the underlying driver can't support t=
he sharing of
> > skbs.
>=20
> My bad, I misread your patch. Seems fine to me ;)
>=20
Ok, thanks.  I'll put this in a local tree and stat auditing drivers to=
 see who
needs it set/cleared.  I'll post a new series when I have it done.

Thanks!
Neil

