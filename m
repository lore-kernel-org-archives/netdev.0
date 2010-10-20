From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Wed, 20 Oct 2010 15:28:51 -0300
Message-ID: <20101020182851.GP8781@llucax.com.ar>
References: <20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
	<20101019201841.GC14410@hmsreliant.think-freely.org>
	<20101020172018.GN8781@llucax.com.ar>
	<0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
	<20101020180454.GC14407@hmsreliant.think-freely.org>
	<0434463FDA60A94FA978ACA44617682DEE846681B9@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>, David Miller <davem@davemloft.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <0434463FDA60A94FA978ACA44617682DEE846681B9@EUSAACMS0702.eamcs.ericsson.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jon Maloy, el 20 de octubre a las 14:10 me escribiste:
> <...>
> > > 
> > > Remember, permitting both is a superset of the current one 
> > (NBO only) 
> > > so it is fully backwards compatible. We break absolutly nothing by 
> > > permitting this.
> > > 
> > Thats effectively reverting both our patches though, isn't it 
> > (not that I'm disagreeing with it, just looking for 
> > clarification).  If we revert my patch and reintroduce the 
> > htohl mechanism which tracks endianess, we might as well 
> > revert the TIPC_SUB_SERVICE flag as well, yeah?
> 
> Absolutely. I think it was a mistake to change that value.
> But I don't think we need to reintroduce the htohl(). That
> was just one way of doing it. If I understood your suggestion
> from yesterday correctly you converted the whole message within
> one if()clause, without any htohl(). I have have no problem with 
> that approach.

There is a difference between both solutions, the htohl() version
tracked the need for swap as a struct subscription member (which was
used when sending back events). Neils patch doesn't do that tracking.
I don't really know the implications of this, but maybe it would be
a wise idea to stay in the safe side and revert both patches for now.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
It's not a lie, if you believe it.
	-- George Constanza

------------------------------------------------------------------------------
Nokia and AT&T present the 2010 Calling All Innovators-North America contest
Create new apps & games for the Nokia N8 for consumers in  U.S. and Canada
$10 million total in prizes - $4M cash, 500 devices, nearly $6M in marketing
Develop with Nokia Qt SDK, Web Runtime, or Java and Publish to Ovi Store 
http://p.sf.net/sfu/nokia-dev2dev
