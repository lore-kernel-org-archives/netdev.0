From: Mariusz Mazur <mmazur@kernel.pl>
Subject: Re: iproute2 and kernel headers
Date: Sun, 8 Aug 2004 11:38:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408081138.09082.mmazur@kernel.pl>
References: <20040805005019.GA11538@bougret.hpl.hp.com> <20040806093920.045b379e@dell_ss3.pdx.osdl.net> <1091847950.1800.6.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>, jt@hpl.hp.com,
        jt@bougret.hpl.hp.com, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1091847950.1800.6.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On sobota 07 sierpie=F1 2004 16:04, jamal wrote:
> > > 	By the way, one of the consequence of versioning the API is
> > > that I tend to do most API changes in batches. The idea is that I w=
ant
> > > to minimise the number of API versions, because I have to test the
> > > tools and drivers with each of them, and I have finite time.
>
> There should really be no reason you have to change versions. It should
> be the last resort. You can use tricks like data structure augmentation
> and and new TLV types to go for a long time and still be backward (as
> well as forward) compatible. When you are no longer capable of doing
> these tricks, then it would make sense upping the version.
> There also should be rules for evolution reasons against having data
> structures which cross kernel/userspace from having things like
> lookatme[0] elements.

If I understand correctly how the new linux-abi headers are supposed to w=
ork -=20
this is the way to go (meaning - new versions of linux-abi should not bre=
ak=20
old stuff if they don't have to).


--=20
In the year eighty five ten
God is gonna shake his mighty head
He'll either say,
"I'm pleased where man has been"
Or tear it down, and start again
