From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Fri, 7 Jun 2013 20:19:15 +0530
Message-ID: <51B1F2EB.80109@ti.com>
References: <51B0254B.4090304@ti.com> <20130606085049.GL31367@sirena.org.uk> <CACRpkdYxsXZBo1p6EefbE7n6XxYZCGokz-yCq03TTbGavaKEvg@mail.gmail.com> <20130607.004234.2007576325541054686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linus.walleij@linaro.org>, <broonie@kernel.org>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<gururaja.hebbar@ti.com>, <benoit.cousson@linaro.org>,
	<linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38511 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab3FGOtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 10:49:35 -0400
In-Reply-To: <20130607.004234.2007576325541054686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/7/2013 1:12 PM, David Miller wrote:
> From: Linus Walleij <linus.walleij@linaro.org>
> Date: Fri, 7 Jun 2013 09:31:58 +0200
>
>> On Thu, Jun 6, 2013 at 10:50 AM, Mark Brown <broonie@kernel.org> wrote:
>>> On Thu, Jun 06, 2013 at 11:29:39AM +0530, Mugunthan V N wrote:
>>>> On 6/6/2013 12:53 AM, Mark Brown wrote:
>>>>> Linus Walleij posted some patches which factor the state setting code
>>>>> out into generic functions earlier on today - it probably makes sense to
>>>>> pick those up rather than open coding
>>>> But this can go in as Linus Walleij's patch is not accepted yet.
>>>> Once that is
>>>> accepted and present in net git repo I will submit a separate patch to use
>>>> those APIs from pin ctrl core.
>>> Linus' change has pretty much gone in already but in any case what would
>>> be sensible here would be to write this in turns of Linus' changes and
>>> then send the patch to him to add to his series so it can go in via the
>>> same route.  One of the major reasons for the patch was that lots of
>>> people were querying the amount of noise caused by this sort of change.
>> I agree. We should be able to settle on the new core API quite soon,
>> then I can carry the patch to this driver if you obtain David's ACK.
> If you want to merge the direct networking parts of this series into
> another tree, I'm fine with that:
>
> Acked-by: David S. Miller <davem@davemloft.net>
David

Can you the below patch series as i have adopted pinctrl PM api in 
another series,
this patch has direct usage of pinctrl_select_state apis
http://marc.info/?l=linux-netdev&m=137054250018667&w=2

Linus Walleij

Please drop this patch series and take my other [atch set mentioned above
with David's Ack.

Regards
Mugunthan V N
