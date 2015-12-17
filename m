From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Thu, 17 Dec 2015 11:19:12 +0800
Message-ID: <20151217031912.GB3821@dhcp-128-65.nay.redhat.com>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
 <20151115192547.3fd1b3cc@mir>
 <1448020533.3141.27.camel@sipsolutions.net>
 <20151123013740.GA27383@dhcp-128-32.nay.redhat.com>
 <1449843990.2324.11.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Lippers-Hollmann <s.l-h@gmx.de>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449843990.2324.11.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 12/11/15 at 03:26pm, Johannes Berg wrote:
> On Mon, 2015-11-23 at 09:37 +0800, Dave Young wrote:
>=20
> > Seems there're a lot of other wireless messages. Should we refactor=
=20
> > them as well? I still did not get chance to see where is the code.
> > (My wireless driver being used is iwlwifi)
>=20
> Most are probably from net/mac80211/.
>=20
> > # dmesg|grep "Limiting TX power"|wc
> > =A0=A0=A04128=A0=A0=A049600=A0=A0360052
> >=20
>=20
> I fixed this one recently, due to a bug it was printed all the time
> instead of just once when taking effect.

Cool, has the fix been in mainline or somewhere else?

Thanks
Dave
