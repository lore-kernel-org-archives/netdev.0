From: Paul Wouters <paul@xelerance.com>
Subject: Re: [Openswan dev] IPComp
Date: Sat, 3 Jul 2004 13:02:56 +0200 (MET DST)
Sender: dev-bounces@lists.openswan.org
Message-ID: <Pine.LNX.4.44.0407031301460.27704-100000@expansionpack.xtdnet.nl>
References: <E1BgYk6-0007M3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Wouters <paul@xelerance.com>
Return-path: <dev-bounces@lists.openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1BgYk6-0007M3-00@gondolin.me.apana.org.au>
Cc: dev@lists.openswan.org
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Jul 2004, Herbert Xu wrote:

> > He mailed me the barfs seperately. the key line is:
> > 
> > Jul  2 15:57:30 vin pluto[29579]: "BRU" #3: ERROR: netlink response for Add SA comp.661a@hhh.hhh.hhh.158 included errno 12: Cannot allocate memory
> > Jul  2 15:57:30 vin pluto[29579]: "BRU" #4: ERROR: netlink response for Add SA comp.661a@hhh.hhh.hhh.158 included errno 12: Cannot allocate memory
> 
> These indicate that a kmalloc in the path of adding IPCOMP SAs failed.
> 
> Hmm, there is a 64K kmalloc in ipcomp_init_state.  That's the most likely
> culprit.  What does cat /proc/slabinfo show?

That information is not listed in the barf.
 
> It'd also be nice to know exactly what kernel version he is using.

2.6.5 

He seems to have generic memory problems though, so I don't think this is an 
openswan or kernel ipsec bug.

Paul
-- 

<Reverend> IRC is just multiplayer notepad.
