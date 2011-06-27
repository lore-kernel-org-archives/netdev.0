From: Matt Turner <mattst88@gmail.com>
Subject: Re: [PATCH] e1000: Allow the driver to be used on PA
 RISC C8000 workstation
Date: Mon, 27 Jun 2011 15:33:43 -0400
Message-ID: <BANLkTimbhOpp624KKU0dEE63mkAC1SDMAg@mail.gmail.com>
References: <A78C6259B11833419567082E2DC0C25601D8A9CA5E@orsmsx508.amr.corp.intel.com>
	<1538517.jd8kKEpd3f@donald.sf-tec.de>
	<2567734.3Tpd1BeV4a@donald.sf-tec.de>
	<1793556.1X3EUabhs6@donald.sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "kyle@mcmartin.ca" <kyle@mcmartin.ca>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, Guy Martin <gmsoft@tuxicoman.be>,
	"mikulas@artax.karlin.mff.cuni.cz" <mikulas@artax.karlin.mff.cuni.cz>
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1793556.1X3EUabhs6@donald.sf-tec.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jun 27, 2011 at 2:42 PM, Rolf Eike Beer <eike-kernel@sf-tec.de> wro=
te:
> Rolf Eike Beer wrote:
>> Am Freitag, 18. M=E4rz 2011, 17:39:57 schrieb Rolf Eike Beer:
>> > Am Mittwoch, 2. M=E4rz 2011, 21:19:24 schrieb Jesse Brandeburg:
>> > > On Mon, Feb 28, 2011 at 5:40 AM, Guy Martin <gmsoft@tuxicoman.be> wr=
ote:
>> > > > Hi Jeff,
>> > > >
>> > > > Any luck getting this into mainline ?
>> > >
>> > > Hi Guy, sorry for the delay,
>> > > We haven't been able to get our contacts in HP to give us a decent
>> > > response so far, we are following up with them to see whats up. =A0We
>> > > have not lost the patch and are still tracking it internally.
>> > >
>> > > Give us a couple more weeks if that is okay and we should be able to
>> > > settle this by then.
>> >
>> > I wonder what exactly you are waiting for? This is a sanity check that
>> > we
>> > disable, so no working systems could get broken by this. And every
>> > single
>> > C8000 seems to be affected by this and is working fine with that patch.
>> > So maybe people at HP might have a clue _why_ this is screwed, but
>> > until then I don't see any point in waiting.
>> >
>> > So please just add my tested-by and push this upstream soon. Since this
>> > is basically a hardware quirk I would like to get this into stable also
>> > so we may run vanilla 2.6.38.1 or something like that on C8000.
>> >
>> > Tested-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
>>
>> For the netdev folks: it's this patch we are talking about
>>
>> http://www.spinics.net/lists/linux-parisc/msg03091.html
>>
>> I would love to see that someone finally picks this up and pushes this
>> upstream, CC stable. This is absolutely annoying as it breaks every time
>> anyone touches the kernel on one of this machines.
>>
>> Jeff, David, James: can you please make a decision of who takes this and
>> then just do it?
>
> Ping?

Ping indeed. Waiting as if HP is going to say "yes, we fucked that up.
Go ahead with the patch." is silly.

---------------------------------------------------------------------------=
---
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security =

threats, fraudulent activity, and more. Splunk takes this data and makes =

sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
