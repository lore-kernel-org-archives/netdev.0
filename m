From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 13:41:06 -0400
Message-ID: <20100602174106.GA6748@hmsreliant.think-freely.org>
References: <alpine.DEB.2.00.1006021126500.30182@router.home>
 <1275496439.2725.203.camel@edumazet-laptop>
 <alpine.DEB.2.00.1006021140320.30182@router.home>
 <20100602.101258.134121018.davem@davemloft.net>
 <1275499150.2519.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55279 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758094Ab0FBRlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:41:15 -0400
Content-Disposition: inline
In-Reply-To: <1275499150.2519.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 02, 2010 at 07:19:10PM +0200, Eric Dumazet wrote:
> Le mercredi 02 juin 2010 =E0 10:12 -0700, David Miller a =E9crit :
> > From: Christoph Lameter <cl@linux-foundation.org>
> > Date: Wed, 2 Jun 2010 11:49:18 -0500 (CDT)
> >=20
> > > On Wed, 2 Jun 2010, Eric Dumazet wrote:
> > >=20
> > >> take a look at
> > >>
> > >> http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/html/S=
ystemTap_Beginners_Guide/useful-systemtap-scripts.html#dropwatch
> > >=20
> > > System tap?
> >=20
> > You don't need to use system tap, just the normal tracing stuff usi=
ng
> > sysfs files suffices.
> >=20
>=20
> It would be good if Neil could gave us a man page or something ;)
>=20
That stap script was really meant to be a stopgap measure.  As mentione=
d, you
can use the debugfs interface to turn tracepoints on and use them anywa=
y you
wish.  Or, if you want to use the kfree_skb and napi_poll tracepoints i=
n a more
formalized way, you can use the dropwatch user space utility:

https://fedorahosted.org/dropwatch/

Which includes a man page on usage :)

I also recently updated it so that this utility can query /proc/kallsym=
s to
translate program counter values into symbollic names and offsets for y=
ou. :)

Regards
Neil

