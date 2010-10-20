From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Wed, 20 Oct 2010 14:04:54 -0400
Message-ID: <20101020180454.GC14407@hmsreliant.think-freely.org>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
	<20101019201841.GC14410@hmsreliant.think-freely.org>
	<20101020172018.GN8781@llucax.com.ar>
	<0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Leandro Lucarella <luca@llucax.com.ar>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>, David Miller <davem@davemloft.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2010 at 01:57:06PM -0400, Jon Maloy wrote:
> <...>
> > subscr struct because 0x0 is a valid filter in TIPC 2.0.
> > =

> =

> > =

> > Another option is to change the TIPC 2.0 specification to use =

> > the old format (use HBO in subscriptions and keep =

> > TIPC_SUB_SERVICE as a separate flag with value 2) and forget =

> > about all this. After all, I can't see what advantages gives =

> > having to change the BO for internal messages between the =

> > applications and the stack.
> =

> I agree with this. I have no problems with changing the draft =

> (which as Leandro already noted is "work-in-progress") to specify that =

> both HBO and NBO are permitted over the wire, and that it is the
> topology server's task to keep track of which one is used.
> =

> Remember, permitting both is a superset of the current one (NBO only)
> so it is fully backwards compatible. We break absolutly nothing by =

> permitting this. =

> =

Thats effectively reverting both our patches though, isn't it (not that I'm
disagreeing with it, just looking for clarification).  If we revert my patc=
h and
reintroduce the htohl mechanism which tracks endianess, we might as well re=
vert
the TIPC_SUB_SERVICE flag as well, yeah?

Neil

> =

> > =

> > [1] http://tipc.sourceforge.net/doc/draft-spec-tipc-06.html
> > [2] http://tipc.sourceforge.net/doc/draft-spec-tipc-06.html#anchor92
> > =

> > -- =

> > Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
> > ----------------------------------------------------------------------
> > GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
> > ----------------------------------------------------------------------
> > CARANCHO OBNUBILADO APARECE EN PARQUE CHACABUCO!
> > 	-- Cr=F3nica TV
> > --
> > To unsubscribe from this list: send the line "unsubscribe =

> > netdev" in the body of a message to majordomo@vger.kernel.org =

> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> =


---------------------------------------------------------------------------=
---
Nokia and AT&T present the 2010 Calling All Innovators-North America contest
Create new apps & games for the Nokia N8 for consumers in  U.S. and Canada
$10 million total in prizes - $4M cash, 500 devices, nearly $6M in marketing
Develop with Nokia Qt SDK, Web Runtime, or Java and Publish to Ovi Store =

http://p.sf.net/sfu/nokia-dev2dev
