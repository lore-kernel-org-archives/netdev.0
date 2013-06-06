From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Thu, 6 Jun 2013 11:29:39 +0530
Message-ID: <51B0254B.4090304@ti.com>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com> <1370452099-24026-2-git-send-email-mugunthanvnm@ti.com> <20130605192345.GH31367@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Hebbar Gururaja <gururaja.hebbar@ti.com>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130605192345.GH31367@sirena.org.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/6/2013 12:53 AM, Mark Brown wrote:
> On Wed, Jun 05, 2013 at 10:38:15PM +0530, Mugunthan V N wrote:
>> From: Hebbar Gururaja <gururaja.hebbar@ti.com>
>>
>> Amend cpsw controller to optionally take a pin control handle and set
>> the state of the pins to:
>>
>> - "default" on boot, resume
>> - "sleep" on suspend()
> Linus Walleij posted some patches which factor the state setting code
> out into generic functions earlier on today - it probably makes sense to
> pick those up rather than open coding
But this can go in as Linus Walleij's patch is not accepted yet. Once 
that is
accepted and present in net git repo I will submit a separate patch to use
those APIs from pin ctrl core.

Regards
Mugunthan V N
