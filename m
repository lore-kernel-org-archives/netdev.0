From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 7 Aug 2008 15:14:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808071454580.4551@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <20080806155306.72039010@tux>
 <Pine.LNX.4.64.0808070950260.3859@wrl-59.cs.helsinki.fi>
 <200808071450.43552.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-476360924-1218111155=:4551"
Cc: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200808071450.43552.denys@visp.net.lb>
Content-ID: <Pine.LNX.4.64.0808071512490.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-476360924-1218111155=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808071512491.4551@wrl-59.cs.helsinki.fi>

On Thu, 7 Aug 2008, Denys Fedoryshchenko wrote:

> On Thursday 07 August 2008, Ilpo Järvinen wrote:
> > On Wed, 6 Aug 2008, Dâniel Fraga wrote:
> > > On Thu, 31 Jul 2008 15:47:55 +0200
> > >
> > > Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> > > > If your problem is really FRTO related (that what the patch is for),
> > > > you could try to disable FRTO temporarily:
> > >
> > > 	Hi, the patch helped, but what's the conclusion? Is the problem
> > > "solved"? Will this patch be merged in the next kernel? This thread
> > > seems to be forgotten.
> >
> > I was yesterday preparing the patch description by adding some more
> > thoughts to it (as if there weren't enough already) but didn't yet send it
> > with new cover (to sort of notify davem).
> >
> > I give no guarantees about the _next_ kernel but some 2.6.26.y and 2.6.27
> > is more likely bet.
> 
> By the way, i had also problem with frto with local connections, and it was 
> trivial to reproduce. But because of proprioetary(but i have sources) 
> userspace application and specific way of using it - i didn't report to 
> maillist.

I could have still looked to it :-), I can mostly decide anything TCP 
congestion control related based on solely a tcpdump, and I can even read 
tcpdump -n -r logfile output if you want to fully hide any payloads (as 
long as the lines are not split to a mess in an email :-)) though then 
plotting them is not as easy for me (I could hack my tool someday though 
to handle that as well).

But if there is pre-2.6.25.7/2.6.26 kernel involved, then it's obsolete 
one and requires upgrade or the relevant fixes from 2.6.25.7.

> But after patch is ready, add me please in cc, i will test it with 
> me too.

I already sent it, though vger was in some sort of distress, so it might 
take some time to arrive...

> For me disabling frto helps to solve problem. With frto i have 
> connections "stalling", if there is trasferred large chunks of data over 
> loopback. It is complicated way how it works all - but i can try to explain 
> how everything works, if required.

Could you just tcpdump over (at least) one stall? ...That would be useful 
even if you find the patch I sent working because it's always possible 
that something has been overlooked in FRTO spec or so and I would like to 
understand the problem rather than just use a workaround which was 
intented to fix (possibly) other problem...

If there's something I cannot figure out from the dump, I'll then consult 
you about the userspace details.


-- 
 i.
---696208474-476360924-1218111155=:4551--
