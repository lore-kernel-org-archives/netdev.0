From: Kosta Todorovic <kostodo@gmail.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Sun, 20 Mar 2005 23:02:53 +0400
Message-ID: <efe3b006050320110226b2dba1@mail.gmail.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <200503182333.51470.jdmason@us.ibm.com>
	 <efe3b0060503190229dff2a01@mail.gmail.com>
	 <200503190757.27727.jdmason@us.ibm.com>
	 <20050319152354.GA4946@electric-eye.fr.zoreil.com>
	 <1111327546.1094.47.camel@jzny.localdomain>
Reply-To: Kosta Todorovic <kostodo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1111327546.1094.47.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Using the standard tulip driver in 64bit mode loads the cards but they
just dont seem to work.
When i tested with "mii-tool -w" it keep saying "Autonegotiation Failed".



On 20 Mar 2005 09:05:46 -0500, jamal <hadi@cyberus.ca> wrote:
> 
> I have those 4 port cards(quiet a few i may add and used in all my
> experiments on NAPI with 10/100 etc for the last few eons) and they work
> just fine with standard linux driver on my 32 bit hardware - not sure
> about 64 bit.
> There is one subtle difference. They use SYM PHY.
> Donald Beckers drivers had this right - the current tulip driver still
> has it wrong. I attempted to incorporate Donalds fixes a while back:
> http://www.cyberus.ca/~hadi/patches/tulip-sym-fixed-20030103.tgz
> 
> In my experience i have found even with current tulip driver no issues
> unless you start doing things like 10Mbps half-duplex. I.e you dont need
> the SYM PHY support.
> 
> cheers,
> jamal
> 
> On Sat, 2005-03-19 at 10:23, Francois Romieu wrote:
> > Jon Mason <jdmason@us.ibm.com> :
> > [...]
> > > The ZNXY website provides the driver source for the 4port adapter (and it is
> > > GPL'ed), but it seems to me that this is really an issue of getting the
> > > adapter to work with the "real" kernel driver, tulip.
> >
> > There are no sources for the rlk.O file and the driver suffers a bit from
> > the usual out-of-tree hal braindamage. Both can probably be worked around
> > but I would not make my business depend on the availability of a sane
> > driver within a reasonable timescale.
> >
> > --
> > Ueimor
> >
> >
> 
>
