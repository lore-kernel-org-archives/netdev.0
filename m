From: jamal <hadi@cyberus.ca>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it
	to another host
Date: 08 Mar 2005 09:10:22 -0500
Message-ID: <1110291022.1050.204.camel@jzny.localdomain>
References: <20050306153108.20430b58.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	 <1110199198.1094.1282.camel@jzny.localdomain>
	 <20050308002643.7eac84e7.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	 <20050307213211.GA25323@outpost.ds9a.nl>
	 <1110238406.1043.57.camel@jzny.localdomain>
	 <20050308115734.544fcaca.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, netdev@oss.sgi.com
To: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
In-Reply-To: <20050308115734.544fcaca.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 20:27, Mark Smith wrote:
> Hi Jamal, Bert,
> 
> On 07 Mar 2005 18:33:26 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > On Mon, 2005-03-07 at 16:32, bert hubert wrote:
> > > On Tue, Mar 08, 2005 at 12:26:43AM +1030, Mark Smith wrote:
> > 
> > I think i got it finally ..
> > 
> > > Indeed, we are in full agreement. The idea is to have the ability to fully
> > > firewall and monitor a machine that absolutely needs to have a real
> > > routable IP address, without wasting an IP address for the router (or trying
> > > to get an ISP to assign you multiple addresses, which can be a major chore
> > > these days).
> > > 
> > > I'd settle for a 'dirty' solution. Remco van Mook of Virtu.nl suggested
> > > abusing iptables -j QUEUE combind with tun/tap to inject the packets on the
> > > ethernet side, where userspace does the PPP -> ethernet conversion by making
> > > up the required headers.
> > >
> 
> A while back I was playing a bit with policy forwarding/routing,
> specifically trying to get traffic for a local address to travel
> "outside" the machine that it was assigned to, rather than short
> circuiting internal to the host.

Yes, I remember that discussion ;-> Alexey wasnt very thrilled.

[Ive deleted the rest of your text for brevity]. 
Note that the redirect at L2 overcomes the issues you were trying ot
address in that email (and infact instead of redirecting you can also
just "mirror")...
So it seems if all you do is bridge and firewall and you never involve
IP then you should be fine.
So maybe the return path as well should have no IP involvment either
and be L2 switched as well.

I think what is needed is some experimenting with some windoz test
clients, a ppp server and the middle proxy machine. Like i said i am
willing to help.

cheers,
jamal
