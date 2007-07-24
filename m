From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Tue, 24 Jul 2007 09:14:46 +0530
Message-ID: <OF782207DD.01F7022B-ON65257322.000F7C16-65257322.0014942E@in.ibm.com>
References: <1185193921.26013.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, davem@davemloft.net, herbert@gondor.apana.org.au
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1185193921.26013.37.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 07/23/2007 06:02:01 PM:

> Yes, and these results were sent to you as well a while back.
> When i get the time when i get back i will look em up in my test machine
> and resend.

Actually you have not sent netperf results with prep and without prep.

> > No. I see value only in non-LLTX drivers which also gets the same TX
lock
> > in the RX path.
>
> So _which_ non-LLTX driver doesnt do that? ;->

I have no idea since I haven't looked at all drivers. Can you tell which
all non-LLTX drivers does that ? I stated this as the sole criterea.

> tun driver doesnt use it either - but i doubt that makes it "bloat"

Adding extra code that is currently not usable (esp from a submission
point)
is bloat.

> You waltz in, have the luxury of looking at my code, presentations, many
> discussions with me etc ...

"luxury" ? I had implemented the entire thing even before knowing that you
are working on something similar! and I had sent the first proposal to
netdev,
*after* which you told that you have your own code and presentations (which
I had never seen earlier - I joined netdev a few months back, earlier I was
working on RDMA, Infiniband as you know). And it didn't give me any great
ideas either, remember I had posted results for E1000 at the time of
sending
the proposals. However I do give credit in my proposal to you for what
ideas
that your provided (without actual code), and the same I did for other
people
who did the same, like Dave, Sridhar. BTW, you too had discussions with me,
and I sent some patches to improve your code too, so it looks like a two
way
street to me (and that is how open source works and should).

> When i ask for differences to code you produced, they now seem to sum up
> to the two below. You dont think theres some honest issue with this
> picture?

Two changes ? That's it ? I gave a big list of changes between our
implementations but you twist my words to conclude there is just two (by
conveniently labelling everything else "cosmetic", or "potentially
useful"!)! Even my restart routine used a single API from the first day,
I would never imagine using multiple API's. Our codes probably doesn't
have even one line that look remotely similar!

To clarify : I suggested that you could send patches for the two *missing*
items if you can show they add value (and not the rest, as I consider
those will not improve the code/logic/algo).

> > ("lacking in frankness, candor, or sincerity; falsely or hypocritically
> > ingenuous; insincere") ???? Sorry, no response to personal comments and
> > have a flame-war :)
>
> Give me a better description.

Sorry, no personal comments. Infact I will avoid responding to baits and
innuendoes from now on.

Thanks,

- KK
