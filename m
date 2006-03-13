From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Mon, 13 Mar 2006 10:04:21 -0800
Message-ID: <20060313100421.7df7f9ed@localhost.localdomain>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142225063.14909.77.camel@ras.pc.brisbane.lube>
	<1142269090.5242.29.camel@jzny2> <4415B217.30507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4415B217.30507@trash.net>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Mon, 13 Mar 2006 18:55:35 +0100
Patrick McHardy <kaber@trash.net> wrote:

> jamal wrote:
> > On Mon, 2006-13-03 at 14:44 +1000, Russell Stuart wrote: 
> > 
> >>You are wrong on both counts.
> > 
> > 
> > I am wrong on why it is being rejected - but what you are seeing is
> > worse than i thought initially. 
> > 
> > Lets put it this way:
> > The only you will _ever_ get that message is if you had made a syntax
> > error (which you did not). Please look at the code on where that message
> > appears and:
> > 
> > a) tell me how you would have got that message to begin with using
> > perfectly legal syntax.
> > a) tell me how a memset would have fixed that.
> 
> He already told you, pack_key expects the selector to be initialized,
> otherwise nkeys might contain a value >= 128, which would cause
> exactly this error, if a matching key is not found within the
> uninitialized memory by accident.
> 
> > Just send the memset fix to Stephen with a different reason. Your
> > current reason is _wrong_ and i really dont have much time to have this
> > kind of discussion.  
> > If you had said "I added that memset there because it looks like the
> > right thing to do" then we would not have had this discussion.
> > 
> > You made claims you fixed a bug. It cant possibly be the bug you fixed.
> > Was it some other bug perhaps and you mixed up the two?

The memset fix is in current CVS. I just wasn't going to take the
patch that looked at utsname to decide what hash to use.

> The patch as well as the description are perfectly fine.
> 
> BTW, running valgrind on tc shows lots of uses of uninitialized values,
> it seems like a good idea if someone would go over these and fix them
> up.

If we had a test script of commands (code coverage), that would help.
