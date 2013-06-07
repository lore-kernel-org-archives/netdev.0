From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Fri, 7 Jun 2013 09:31:58 +0200
Message-ID: <CACRpkdYxsXZBo1p6EefbE7n6XxYZCGokz-yCq03TTbGavaKEvg@mail.gmail.com>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
	<1370452099-24026-2-git-send-email-mugunthanvnm@ti.com>
	<20130605192345.GH31367@sirena.org.uk>
	<51B0254B.4090304@ti.com>
	<20130606085049.GL31367@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Hebbar Gururaja <gururaja.hebbar@ti.com>,
	benoit.cousson@linaro.org, Linux-OMAP <linux-omap@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130606085049.GL31367@sirena.org.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 6, 2013 at 10:50 AM, Mark Brown <broonie@kernel.org> wrote:
> On Thu, Jun 06, 2013 at 11:29:39AM +0530, Mugunthan V N wrote:
>> On 6/6/2013 12:53 AM, Mark Brown wrote:
>
>> >Linus Walleij posted some patches which factor the state setting code
>> >out into generic functions earlier on today - it probably makes sense to
>> >pick those up rather than open coding
>
>> But this can go in as Linus Walleij's patch is not accepted yet.
>> Once that is
>> accepted and present in net git repo I will submit a separate patch to use
>> those APIs from pin ctrl core.
>
> Linus' change has pretty much gone in already but in any case what would
> be sensible here would be to write this in turns of Linus' changes and
> then send the patch to him to add to his series so it can go in via the
> same route.  One of the major reasons for the patch was that lots of
> people were querying the amount of noise caused by this sort of change.

I agree. We should be able to settle on the new core API quite soon,
then I can carry the patch to this driver if you obtain David's ACK.

Yours,
Linus Walleij
