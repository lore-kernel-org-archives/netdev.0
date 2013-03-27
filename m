From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors
Date: Wed, 27 Mar 2013 18:51:38 +0100
Message-ID: <20130327175138.GA5717@localhost>
References: <1363675513.4767.6.camel@nexus>
 <51515E5E.7020309@lab.ntt.co.jp>
 <20130326104833.GA5331@localhost>
 <51527239.5070505@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	linux-man@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hirotaka Sasaki <sasaki.hirotaka@lab.ntt.co.jp>
To: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51527239.5070505@lab.ntt.co.jp>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fernando,

On Wed, Mar 27, 2013 at 01:14:49PM +0900, Fernando Luis Vazquez Cao wrote:
> Hi Pablo,
> 
> On 2013/03/26 19:48, Pablo Neira Ayuso wrote:
> >On Tue, Mar 26, 2013 at 05:37:50PM +0900, Fernando Luis Vazquez Cao wrote:
> >>Hi Michael,
> >>
> >>Do you see any problem with these two patches?
> >Please, hold on with the second patch.
> 
> Are you Ok with getting patch 1 merged while be discuss
> what to do about the issue that the second patch tried to
> document? Could I get your "Acked-by" for it?

Done.

> >I'd like to find a possible solution for the EPERM problem that we've
> >been discussing. It requires some rework and performance evaluation.
> 
> The problem is that there is a huge installed base of
> systems that show this broken behaviour, so even if
> we find a proper fix for it we still should document
> which systems may be affected by the spurious EPERM
> bug, thus giving application programmers a chance to
> add logic to their programs to recover from such
> eventualities.

I see. The problem is that it will take some time until that manpage
update reaches main distributions, by that time we may have fixed it
already in existing kernels. Then, we'll have to remove it again. I
still think patch 1 already provides some clue to programmers
regarding EPERM at this moment (even if not so explicit and detailed).

Please, ping me again if we didn't come up with some solution for this
in some prudential amount of time.

Regards.
